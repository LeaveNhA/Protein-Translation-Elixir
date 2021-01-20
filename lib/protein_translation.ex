defmodule ProteinTranslation do
  @doc """
  Given an RNA string, return a list of proteins specified by codons, in order.
  """
  @spec of_rna(String.t()) :: {atom, list(String.t())}
  def of_rna(rna) do
    rna_charlist = rna |> to_charlist

    if invalid?(rna_charlist) do
      {:error, "invalid RNA"}
    else
      rna_charlist
      |> Enum.chunk_every(3)
      |> Enum.map(&ProteinTranslation.of_codon/1)
      |> Enum.map(fn {:ok, x} -> x end)
      |> Enum.reduce_while([], fn elm, acc ->
        if elm == "STOP", do: {:halt, acc}, else: {:cont, acc ++ [elm]}
      end)
      |> fn r -> {:ok, r} end.()
    end
  end

  @doc """
  Given a codon, return the corresponding protein

  UGU -> Cysteine
  UGC -> Cysteine
  UUA -> Leucine
  UUG -> Leucine
  AUG -> Methionine
  UUU -> Phenylalanine
  UUC -> Phenylalanine
  UCU -> Serine
  UCC -> Serine
  UCA -> Serine
  UCG -> Serine
  UGG -> Tryptophan
  UAU -> Tyrosine
  UAC -> Tyrosine
  UAA -> STOP
  UAG -> STOP
  UGA -> STOP
  """
  @spec of_codon(String.t()) :: {atom, String.t()}
  def of_codon(codon) do
    codons = %{
      'UGU' => "Cysteine",
      'UGC' => "Cysteine",
      'UUA' => "Leucine",
      'UUG' => "Leucine",
      'AUG' => "Methionine",
      'UUU' => "Phenylalanine",
      'UUC' => "Phenylalanine",
      'UCU' => "Serine",
      'UCC' => "Serine",
      'UCA' => "Serine",
      'UCG' => "Serine",
      'UGG' => "Tryptophan",
      'UAU' => "Tyrosine",
      'UAC' => "Tyrosine",
      'UAA' => "STOP",
      'UAG' => "STOP",
      'UGA' => "STOP",
    }

    charlist_codon = codon |> to_charlist

    error? =
    charlist_codon
    |> invalid?

    if error? do
      {:error, "invalid codon"}
    else
      charlist_codon
      |> fn x -> codons[x] end.()
      |> normalize
      |> fn r -> {:ok, r} end.()
    end
  end

  defp invalid?(rna) do
    rna
    # ----------------------------A----------C----------G----------U------
    |> Enum.filter(fn x -> !(x == 65 or x == 67 or x == 71 or x == 85) end)
    |> Enum.count
    |> fn x -> x > 0 end.()
  end

  defp normalize([item]), do: item
  defp normalize(list),   do: list
end
