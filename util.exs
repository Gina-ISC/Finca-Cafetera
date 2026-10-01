defmodule Util do
 @moduledoc """
  Modulo de utilidades para manejo de entrada/salida.
  """

  @doc """
  Lee un dato desde la consola segun el tipo indicado (:string, :integer
  o :float).
  """
  def leer(mensaje, :string) do
    IO.gets(mensaje)
    |> String.trim()
  end

  def leer(mensaje, :integer) do
    leer_con_parser(mensaje, &Integer.parse/1, 0)
  end

  def leer(mensaje, :float) do
    leer_con_parser(mensaje, &Float.parse/1, 0.0)
  end

  # Funcion auxiliar que captura el texto, aplica la funcion de parseo
    defp leer_con_parser(mensaje, funcion, valor_defecto) do
    valor =
      IO.gets(mensaje)
      |> String.trim()
      |> funcion.()

    case valor do
      {numero, _} -> numero
      :error ->
        imprimir_error("Error. Se utilizara #{valor_defecto} como valor predeterminado.")
        valor_defecto
    end
  end

  @doc """
  Imprime un mensaje de error en la salida estandar de error.
  """
  def imprimir_error(mensaje) do
    IO.puts(:standard_error, mensaje)
  end

  @doc """
  Imprime un mensaje normal en la consola.
  """
  def imprimir_mensaje(mensaje) do
    IO.puts(mensaje)
  end
end
