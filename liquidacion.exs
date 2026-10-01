defmodule Liquidacion do
  @moduledoc """
  Calcula cuánto se le paga a cada recolector, a partir únicamente de los
  pesajes que ya pasaron la validación.

  El valor de un pesaje es kilos x tarifa base, bonificación o descuento de calidad.
  Un recolector que reúna 120 kilos o más en un mismo día recibe una bonificación fija por ese día.
  A quien paga la alimentación en la finca se le descuenta un valor fijo por cada día
  neto = valor de los pesajes + bonificaciones - descuento de alimentación.
  """

  @tarifa_base 1_000.0

  # Ajuste por calidad, según el porcentaje de verdes de la muestra.
  @limite_verdes_bonificacion 2
  @limite_verdes_sin_ajuste 5
  @limite_verdes_descuento_leve 10
  @factor_bonificacion_calidad 1.05
  @factor_sin_ajuste 1.0
  @factor_descuento_leve 0.90
  @factor_descuento_alto 0.70

  # Bonificación por productividad.
  @kilos_para_bonificacion 120
  @bonificacion_diaria 8_000.0

  # Descuento de alimentación.
  @descuento_alimentacion_por_dia 12_000.0

  @sin_valor 0.0

  @doc """
  Liquida a todos los recolectores. Retorna una lista de mapas, uno por
  recolector, con su código, nombre, kilos totales, días trabajados, valor
  de los pesajes, bonificación, descuento de alimentación y neto a pagar.
  """
  def liquidar(recolectores, pesajes_validos) do
    Enum.map(recolectores, &liquidar_recolector(&1, pesajes_validos))
  end

  defp liquidar_recolector(recolector, pesajes_validos) do
    pesajes_del_recolector = Enum.filter(pesajes_validos, &(&1.recolector == recolector.codigo))

    valor_pesajes = pesajes_del_recolector |> Enum.map(&valor_pesaje/1) |> Enum.sum()
    bonificacion = calcular_bonificacion(pesajes_del_recolector)
    dias_trabajados = pesajes_del_recolector |> Enum.map(& &1.dia) |> Enum.uniq() |> length()
    descuento = calcular_descuento_alimentacion(recolector.alimentacion, dias_trabajados)
    kilos_totales = pesajes_del_recolector |> Enum.map(& &1.kilos) |> Enum.sum()

    %{
      codigo: recolector.codigo,
      nombre: recolector.nombre,
      kilos_totales: kilos_totales,
      dias_trabajados: dias_trabajados,
      valor_pesajes: valor_pesajes,
      bonificacion: bonificacion,
      descuento_alimentacion: descuento,
      bruto: valor_pesajes + bonificacion,
      neto: valor_pesajes + bonificacion - descuento
    }
  end

  @doc """
  Valor en pesos de un único pesaje válido: kilos por tarifa base, con el
  ajuste de calidad correspondiente a su porcentaje de verdes.
  """
  def valor_pesaje(%{kilos: kilos, verdes: verdes}) do
    kilos * @tarifa_base * factor_calidad(verdes)
  end

  defp factor_calidad(verdes) when verdes <= @limite_verdes_bonificacion,
    do: @factor_bonificacion_calidad

  defp factor_calidad(verdes) when verdes <= @limite_verdes_sin_ajuste, do: @factor_sin_ajuste

  defp factor_calidad(verdes) when verdes <= @limite_verdes_descuento_leve,
    do: @factor_descuento_leve

  defp factor_calidad(_verdes), do: @factor_descuento_alto

  # Suma los kilos válidos de cada día y paga la bonificación fija por cada dia

  defp calcular_bonificacion(pesajes_del_recolector) do
    dias_con_bonificacion =
      pesajes_del_recolector
      |> Enum.group_by(& &1.dia, & &1.kilos)
      |> Enum.map(fn {_dia, kilos_del_dia} -> Enum.sum(kilos_del_dia) end)
      |> Enum.count(&(&1 >= @kilos_para_bonificacion))

    dias_con_bonificacion * @bonificacion_diaria
  end

  defp calcular_descuento_alimentacion(true, dias_trabajados),
    do: dias_trabajados * @descuento_alimentacion_por_dia

  defp calcular_descuento_alimentacion(false, _dias_trabajados), do: @sin_valor

  def detalle_por_dia(pesajes_del_recolector) do
    pesajes_del_recolector
    |> Enum.group_by(& &1.dia)
    |> Enum.map(fn {dia, pesajes} ->
      kilos = pesajes |> Enum.map(& &1.kilos) |> Enum.sum()
      valor = pesajes |> Enum.map(&valor_pesaje/1) |> Enum.sum()
      %{dia: dia, kilos: kilos, valor: valor, bonificacion: calcular_bonificacion_dia(kilos)}
    end)
    |> Enum.sort_by(& &1.dia)
  end

  defp calcular_bonificacion_dia(kilos) when kilos >= @kilos_para_bonificacion,
    do: @bonificacion_diaria

  defp calcular_bonificacion_dia(_kilos), do: 0.0
end
