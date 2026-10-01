defmodule Reportes do
  @moduledoc """
  Construye el texto de los reportes sobre la producción semanal.
  Ninguna función imprime: solo arma y devuelve el texto.
  """

  @meta_diaria 400
  @minimo_pesajes_calidad 3

  # R1. Pesajes rechazados con su motivo y cantidad por motivo

  def reporte_rechazados(pesajes_invalidos) do
    detalle =
      pesajes_invalidos
      |> Enum.map(fn {pesaje, motivo} ->
        "  Recolector: #{pesaje.recolector} | Lote: #{pesaje.lote} | Dia: #{inspect(pesaje.dia)} | " <>
          "Kilos: #{inspect(pesaje.kilos)} | Verdes: #{inspect(pesaje.verdes)} -> #{motivo}"
      end)
      |> Enum.join("\n")

    conteo =
      pesajes_invalidos
      |> Enum.map(fn {_pesaje, motivo} -> motivo end)
      |> Enum.frequencies()
      |> Enum.sort_by(fn {_motivo, cantidad} -> -cantidad end)
      |> Enum.map(fn {motivo, cantidad} -> "  #{motivo}: #{cantidad}" end)
      |> Enum.join("\n")

    "Pesajes rechazados (#{length(pesajes_invalidos)}) \n" <>
      detalle <>
      "\n Cantidad de rechazos por motivo: \n" <>
      conteo
  end

  # R2. Kilos por lote y rendimiento en kg/ha, ordenado por rendimiento.

  def reporte_produccion_por_lote(pesajes_validos, lotes) do
    kilos_por_lote =
      pesajes_validos
      |> Enum.group_by(& &1.lote, & &1.kilos)
      |> Enum.map(fn {id_lote, kilos} -> {id_lote, Enum.sum(kilos)} end)
      |> Map.new()

    detalle =
      lotes
      |> Enum.map(fn lote ->
        kilos = Map.get(kilos_por_lote, lote.id, 0)
        %{lote: lote, kilos: kilos, rendimiento: kilos / lote.hectareas}
      end)
      |> Enum.sort_by(& &1.rendimiento, :desc)
      |> Enum.map(fn %{lote: lote, kilos: kilos, rendimiento: rendimiento} ->
        "#{lote.id} - #{lote.nombre} (#{lote.hectareas} ha): " <>
          "#{formatear(kilos)} kg | rendimiento: #{formatear(rendimiento)} kg/ha"
      end)
      |> Enum.join("\n")

    " Kilos y rendimiento por lote \n" <> detalle
  end

  # R3. Kilos de la finca en cada uno de los 6 días y meta diaria

  def reporte_produccion_diaria(pesajes_validos) do
    kilos_por_dia =
      pesajes_validos
      |> Enum.group_by(& &1.dia, & &1.kilos)
      |> Enum.map(fn {dia, kilos} -> {dia, Enum.sum(kilos)} end)
      |> Map.new()

    detalle =
      1..6
      |> Enum.map(fn dia ->
        kilos = Map.get(kilos_por_dia, dia, 0)
        "Dia #{dia}: #{formatear(kilos)} kg #{estado_meta(kilos)}"
      end)
      |> Enum.join("\n")

    kilos_de_cada_dia = Enum.map(1..6, fn dia -> Map.get(kilos_por_dia, dia, 0) end)
    cumplida_todos = Enum.all?(kilos_de_cada_dia, &(&1 >= @meta_diaria))
    cumplida_alguno = Enum.any?(kilos_de_cada_dia, &(&1 >= @meta_diaria))

    " Produccion diaria frente a la meta \n" <>
      detalle <>
      "\n Se cumplio la meta todos los dias? #{si_o_no(cumplida_todos)} \n" <>
      "Se cumplio la meta al menos un dia? #{si_o_no(cumplida_alguno)}"
  end

  # R4. Liquidación de todos los recolectores, numerada y por neto desc

  def reporte_liquidacion(liquidaciones) do
    detalle =
      liquidaciones
      |> Enum.sort_by(& &1.neto, :desc)
      |> Enum.with_index(1)
      |> Enum.map(fn {liquidacion, posicion} ->
        "#{posicion}. #{liquidacion.codigo} - #{liquidacion.nombre}\n" <>
          "   Kilos: #{formatear(liquidacion.kilos_totales)}\n" <>
          "   Valor pesajes: $#{formatear(liquidacion.valor_pesajes)}\n" <>
          "   Bonificacion: $#{formatear(liquidacion.bonificacion)}\n" <>
          "   Alimentacion: -$#{formatear(liquidacion.descuento_alimentacion)}\n" <>
          "   Neto: $#{formatear(liquidacion.neto)}"
      end)
      |> Enum.join("\n")

    "Liquidacion de recolectores \n" <> detalle
  end

  # R5. Mejor recolector de cada día y quién ganó más días

  def reporte_mejor_recolector_diario(pesajes_validos, recolectores) do
    ganadores_por_dia =
      Enum.map(1..6, fn dia -> ganadores_del_dia(dia, pesajes_validos, recolectores) end)

    detalle =
      ganadores_por_dia
      |> Enum.map(fn
        {dia, :sin_pesajes, _} ->
          "Dia #{dia}: sin pesajes validos"

        {dia, kilos, ganadores} ->
          "Dia #{dia}: #{Enum.join(ganadores, ", ")} con #{formatear(kilos)} kg"
      end)
      |> Enum.join("\n")

    resumen =
      ganadores_por_dia
      |> Enum.flat_map(fn
        {_dia, :sin_pesajes, _} -> []
        {_dia, _kilos, ganadores} -> ganadores
      end)
      |> Enum.frequencies()

    resumen_texto =
      case Map.values(resumen) do
        [] ->
          "Ningun recolector tuvo pesajes validos en la semana."

        _valores ->
          maximo = resumen |> Map.values() |> Enum.max()

          mejores =
            resumen
            |> Enum.filter(fn {_nombre, dias} -> dias == maximo end)
            |> Enum.map(fn {nombre, _dias} -> nombre end)

          "Mejor recolector en mas dias: #{Enum.join(mejores, ", ")} (#{maximo} dias)"
      end

    "Mejor recolector de cada dia \n" <> detalle <> "\n" <> resumen_texto
  end

  # R6. Recolector con mejor calidad (menor % de verdes ponderado)

  def reporte_mejor_calidad(pesajes_validos, recolectores) do
    candidatos =
      pesajes_validos
      |> Enum.group_by(& &1.recolector)
      |> Enum.filter(fn {_codigo, pesajes} -> length(pesajes) >= @minimo_pesajes_calidad end)
      |> Enum.map(fn {codigo, pesajes} -> {codigo, verdes_ponderado(pesajes), length(pesajes)} end)

    cuerpo =
      case candidatos do
        [] ->
          "Ningun recolector tiene al menos #{@minimo_pesajes_calidad} pesajes validos."

        _con_candidatos ->
          mejor = candidatos |> Enum.map(fn {_c, ponderado, _n} -> ponderado end) |> Enum.min()

          candidatos
          |> Enum.filter(fn {_codigo, ponderado, _n} -> ponderado == mejor end)
          |> Enum.map(fn {codigo, ponderado, cantidad} ->
            "#{nombre_de(codigo, recolectores)}: #{formatear(ponderado)}% de verdes ponderado (#{cantidad} pesajes)"
          end)
          |> Enum.join("\n")
      end

    "Recolector con mejor calidad \n" <> cuerpo
  end

  # R7. Total pagado y costo promedio por kilo

  def reporte_pago_total(liquidaciones, pesajes_validos) do
    total_pagado = liquidaciones |> Enum.map(& &1.neto) |> Enum.sum()
    kilos_validos = pesajes_validos |> Enum.map(& &1.kilos) |> Enum.sum()

    costo_por_kilo =
      case kilos_validos do
        0 -> 0.0
        _ -> total_pagado / kilos_validos
      end

    "Totales de la semana \n" <>
      "Total a pagar $#{formatear(total_pagado)}\n" <>
      "Kilos validos: #{formatear(kilos_validos)} kg \n" <>
      "Costo promedio por kilo: $#{formatear(costo_por_kilo)}"
  end

  # R8. Recolectores que trabajaron en todos los lotes

  def reporte_todos_los_lotes(pesajes_validos, lotes, recolectores) do
    total_lotes = length(lotes)

    completos =
      pesajes_validos
      |> Enum.group_by(& &1.recolector, & &1.lote)
      |> Enum.filter(fn {_codigo, lotes_trabajados} ->
        lotes_trabajados |> Enum.uniq() |> length() == total_lotes
      end)
      |> Enum.map(fn {codigo, _} -> nombre_de(codigo, recolectores) end)

    cuerpo =
      case completos do
        [] -> "Ningun recolector trabajo en todos los lotes."
        nombres -> Enum.join(nombres, "\n")
      end

    "Recolectores que trabajaron en todos los lotes \n" <> cuerpo
  end

  # C.1. Ranking con keyword list

  def ranking(liquidaciones, opciones) do
    campo = Keyword.get(opciones, :campo, :neto)
    orden = Keyword.get(opciones, :orden, :desc)
    limite = Keyword.get(opciones, :limite, length(liquidaciones))
    clave = clave_del_campo(campo)

    detalle =
      liquidaciones
      |> Enum.sort_by(&Map.get(&1, clave), orden)
      |> Enum.take(limite)
      |> Enum.with_index(1)
      |> Enum.map(fn {liquidacion, posicion} ->
        "#{posicion}. #{liquidacion.codigo} - #{liquidacion.nombre}: #{formatear(Map.get(liquidacion, clave))}"
      end)
      |> Enum.join("\n")

    "Ranking (campo: #{campo}, orden: #{orden}) \n" <> detalle
  end

  defp clave_del_campo(:neto), do: :neto
  defp clave_del_campo(:kilos), do: :kilos_totales
  defp clave_del_campo(:bruto), do: :bruto
  defp clave_del_campo(_otro), do: :neto

  # C.2. Combinar con la finca vecina

  def combinar_con_vecina(kilos_finca, finca_vecina) do
    Map.merge(kilos_finca, finca_vecina, fn _dia, kilos_finca, kilos_vecina ->
      kilos_finca + kilos_vecina
    end)
  end

  def kilos_por_dia(pesajes_validos) do
    pesajes_validos
    |> Enum.group_by(& &1.dia, & &1.kilos)
    |> Enum.map(fn {dia, kilos} -> {dia, Enum.sum(kilos)} end)
    |> Map.new()
  end

  # Auxiliares privadas

  defp ganadores_del_dia(dia, pesajes_validos, recolectores) do
    kilos_por_recolector =
      pesajes_validos
      |> Enum.filter(&(&1.dia == dia))
      |> Enum.group_by(& &1.recolector, & &1.kilos)
      |> Enum.map(fn {codigo, kilos} -> {codigo, Enum.sum(kilos)} end)

    case kilos_por_recolector do
      [] ->
        {dia, :sin_pesajes, []}

      _no_vacio ->
        maximo = kilos_por_recolector |> Enum.map(fn {_codigo, kilos} -> kilos end) |> Enum.max()

        ganadores =
          kilos_por_recolector
          |> Enum.filter(fn {_codigo, kilos} -> kilos == maximo end)
          |> Enum.map(fn {codigo, _kilos} -> nombre_de(codigo, recolectores) end)

        {dia, maximo, ganadores}
    end
  end

  defp verdes_ponderado(pesajes) do
    suma_kilos = pesajes |> Enum.map(& &1.kilos) |> Enum.sum()
    suma_verdes_por_kilos = pesajes |> Enum.map(&(&1.verdes * &1.kilos)) |> Enum.sum()
    suma_verdes_por_kilos / suma_kilos
  end

  defp nombre_de(codigo, recolectores) do
    recolectores
    |> Enum.find(&(&1.codigo == codigo))
    |> case do
      nil -> codigo
      recolector -> recolector.nombre
    end
  end

  defp estado_meta(kilos) when kilos >= @meta_diaria, do: "(cumplio la meta)"
  defp estado_meta(_kilos), do: "(no llego a la meta)"

  defp si_o_no(true), do: "Si"
  defp si_o_no(false), do: "No"

  defp formatear(valor) when is_integer(valor), do: formatear(valor * 1.0)
  defp formatear(valor), do: :erlang.float_to_binary(valor, decimals: 2)
end
