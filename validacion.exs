defmodule Validacion do
  @moduledoc """
  Valida los pesajes anotados por el mayordomo antes de que entren a
  cualquier cálculo. Cada pesaje se revisa en un orden fijo y se rechaza
  con el primer motivo que aplique
  """

  @dia_minimo 1
  @dia_maximo 6
  @kilos_maximo 250
  @verdes_minimo 0
  @verdes_maximo 100

  @doc """
  Valida un único pesaje contra la lista de recolectores
  """
  def validar_pesaje(pesaje, recolectores, lotes) do
    with {:ok, _codigo} <- validar_recolector(pesaje.recolector, recolectores),
         {:ok, _lote} <- validar_lote(pesaje.lote, lotes),
         {:ok, _dia} <- validar_dia(pesaje.dia),
         {:ok, _kilos} <- validar_kilos(pesaje.kilos),
         {:ok, _verdes} <- validar_verdes(pesaje.verdes) do
      {:ok, pesaje}
    end
  end

  @doc """
  Interpreta la línea de pesaje adicional
  """
  def parsear_pesaje_adicional(linea) do
    case String.split(linea, ";") do
      [recolector, lote, dia_texto, kilos_texto, verdes_texto] ->
        with {:ok, dia} <- parsear_entero(dia_texto),
             {:ok, kilos} <- parsear_numero(kilos_texto),
             {:ok, verdes} <- parsear_numero(verdes_texto) do
          pesaje = %{
            recolector: String.trim(recolector),
            lote: String.trim(lote),
            dia: dia,
            kilos: kilos,
            verdes: verdes
          }

          {:ok, pesaje}
        end

      _cantidad_de_campos_distinta_de_cinco ->
        {:error, :formato_invalido}
    end
  end

  defp parsear_entero(texto) do
    case Integer.parse(String.trim(texto)) do
      {numero, ""} -> {:ok, numero}
      _no_es_entero -> {:error, :formato_invalido}
    end
  end

  defp parsear_numero(texto) do
    texto_recortado = String.trim(texto)

    case Integer.parse(texto_recortado) do
      {numero, ""} ->
        {:ok, numero}

      _no_es_entero ->
        case Float.parse(texto_recortado) do
          {numero, ""} -> {:ok, numero}
          _no_es_numero -> {:error, :formato_invalido}
        end
    end
  end

  @doc """
  Clasifica una lista de pesajes en válidos e inválidos.
  """
  def clasificar(pesajes, recolectores, lotes) do
    resultados = Enum.map(pesajes, &validar_pesaje(&1, recolectores, lotes))
    pares = Enum.zip(pesajes, resultados)

    validos =
      resultados
      |> Enum.filter(&resultado_valido?/1)
      |> Enum.map(fn {:ok, pesaje} -> pesaje end)

    invalidos =
      pares
      |> Enum.filter(fn {_pesaje, resultado} -> not resultado_valido?(resultado) end)
      |> Enum.map(fn {pesaje, {:error, motivo}} -> {pesaje, motivo} end)

    {validos, invalidos}
  end

  defp resultado_valido?({:ok, _pesaje}), do: true
  defp resultado_valido?({:error, _motivo}), do: false


  # Validaciones de cada uno


  defp validar_recolector(codigo, recolectores) do
    if Enum.any?(recolectores, &(&1.codigo == codigo)) do
      {:ok, codigo}
    else
      {:error, :recolector_desconocido}
    end
  end

  defp validar_lote(id_lote, lotes) do
    if Enum.any?(lotes, &(&1.id == id_lote)) do
      {:ok, id_lote}
    else
      {:error, :lote_desconocido}
    end
  end

  defp validar_dia(dia) when is_integer(dia) and dia >= @dia_minimo and dia <= @dia_maximo,
    do: {:ok, dia}

  defp validar_dia(_dia), do: {:error, :dia_invalido}

  defp validar_kilos(kilos) when is_number(kilos) and kilos > 0 and kilos <= @kilos_maximo,
    do: {:ok, kilos}

  defp validar_kilos(_kilos), do: {:error, :kilos_fuera_de_rango}

  defp validar_verdes(verdes)
       when is_number(verdes) and verdes >= @verdes_minimo and verdes <= @verdes_maximo,
       do: {:ok, verdes}

  defp validar_verdes(_verdes), do: {:error, :porcentaje_invalido}
end
