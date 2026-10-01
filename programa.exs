defmodule Programa do
  @moduledoc """
    Flujo principal del programa
  """

  def main do
    recolectores = Datos.recolectores()
    lotes = Datos.lotes()
    pesajes = Datos.pesajes()

    {validos, invalidos} = Validacion.clasificar(pesajes, recolectores, lotes)
    {validos, invalidos} = pedir_pesaje(validos, invalidos, recolectores, lotes)

    liquidaciones = Liquidacion.liquidar(recolectores, validos)

    # Reportes
    Util.imprimir_mensaje(Reportes.reporte_rechazados(invalidos))
    Util.imprimir_mensaje(Reportes.reporte_produccion_por_lote(validos, lotes))
    Util.imprimir_mensaje(Reportes.reporte_produccion_diaria(validos))
    Util.imprimir_mensaje(Reportes.reporte_liquidacion(liquidaciones))
    Util.imprimir_mensaje(Reportes.reporte_mejor_recolector_diario(validos, recolectores))
    Util.imprimir_mensaje(Reportes.reporte_mejor_calidad(validos, recolectores))
    Util.imprimir_mensaje(Reportes.reporte_pago_total(liquidaciones, validos))
    Util.imprimir_mensaje(Reportes.reporte_todos_los_lotes(validos, lotes, recolectores))

    # Ranking
    Util.imprimir_mensaje(Reportes.ranking(liquidaciones, []))
    Util.imprimir_mensaje(Reportes.ranking(liquidaciones, campo: :kilos, limite: 3))
    Util.imprimir_mensaje(Reportes.ranking(liquidaciones, orden: :asc, campo: :bruto))

    # Combinación con la finca vecina
    finca_vecina = %{1 => 520.5, 2 => 610, 3 => 480, 5 => 700, 7 => 300}
    kilos_finca = Reportes.kilos_por_dia(validos)
    Util.imprimir_mensaje("Combinacion con la finca vecina:")
    IO.inspect(Reportes.combinar_con_vecina(kilos_finca, finca_vecina))

    # Desprendible
    desprendible(validos, recolectores, liquidaciones)
  end

  # Pesaje adicional

  defp pedir_pesaje(validos, invalidos, recolectores, lotes) do
    linea = Util.leer("Ingrese un pesaje adicional o Enter para omitir: ", :string)

    case linea do
      "" ->
        Util.imprimir_mensaje("No se agrego ningun pesaje.")
        {validos, invalidos}

      _ ->
        case Validacion.parsear_pesaje_adicional(linea) do
          {:ok, pesaje} ->
            case Validacion.validar_pesaje(pesaje, recolectores, lotes) do
              {:ok, pesaje} ->
                Util.imprimir_mensaje("Pesaje agregado correctamente.")
                {[pesaje | validos], invalidos}

              {:error, motivo} ->
                Util.imprimir_mensaje("Pesaje rechazado: #{motivo}")
                {validos, [{pesaje, motivo} | invalidos]}
            end

          {:error, :formato_invalido} ->
            Util.imprimir_mensaje("Pesaje rechazado: formato_invalido")
            {validos, invalidos}
        end
    end
  end

  # Desprendible

  defp desprendible(validos, recolectores, liquidaciones) do
    codigo = Util.leer("Ingrese el codigo del recolector: ", :string)

    case Enum.find(recolectores, &(&1.codigo == codigo)) do
      nil ->
        Util.imprimir_mensaje("No existe un recolector con el codigo #{codigo}.")

      recolector ->
        pesajes_del = Enum.filter(validos, &(&1.recolector == codigo))
        liquidacion = Enum.find(liquidaciones, &(&1.codigo == codigo))
        detalle = Liquidacion.detalle_por_dia(pesajes_del)

        Util.imprimir_mensaje(Reportes.desprendible(recolector, liquidacion, detalle))
    end
  end
end

Programa.main()
