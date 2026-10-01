defmodule Datos do
  @moduledoc """
  Fuente de datos de la finca cafetera
  """

  @doc """
  Recolectores de la finca. Cada mapa tiene :codigo, :nombre
  y :alimentacion (true si el recolector come en la finca).
  """
  def recolectores do
    [
      %{codigo: "R01", nombre: "Luz Marina Ospina", alimentacion: true},
      %{codigo: "R02", nombre: "Jose Antonio Ramirez", alimentacion: false},
      %{codigo: "R03", nombre: "Carmen Elisa Duque", alimentacion: true},
      %{codigo: "R04", nombre: "Wilson Alberto Gomez", alimentacion: false},
      %{codigo: "R05", nombre: "Maria Fernanda Cardona", alimentacion: true},
      %{codigo: "R06", nombre: "Hector Ivan Marin", alimentacion: false},
      %{codigo: "R07", nombre: "Rosa Amparo Tabares", alimentacion: true},
      %{codigo: "R08", nombre: "Luis Fernando Osorio", alimentacion: false},
      %{codigo: "R09", nombre: "Gloria Ines Salazar", alimentacion: false},
      %{codigo: "R10", nombre: "Edgar Dario Villegas", alimentacion: false}
    ]
  end

  @doc """
  Lotes de la finca. Cada mapa tiene :id, :nombre y :hectareas.
  """
  def lotes do
    [
      %{id: "L1", nombre: "El Mirador", hectareas: 2.5},
      %{id: "L2", nombre: "La Esperanza", hectareas: 1.8},
      %{id: "L3", nombre: "Buenavista", hectareas: 3.2},
      %{id: "L4", nombre: "El Recuerdo", hectareas: 1.2}
    ]
  end

  @doc """
  Pesajes anotados a mano por el mayordomo durante la semana.
  """
  def pesajes do
    [
      # --- Pesajes válidos: al menos 80 en total, en los 6 días ---

      # Día 1
      %{recolector: "R01", lote: "L1", dia: 1, kilos: 70, verdes: 1.5},
      %{recolector: "R01", lote: "L2", dia: 1, kilos: 55, verdes: 6},
      %{recolector: "R02", lote: "L1", dia: 1, kilos: 60, verdes: 3},
      %{recolector: "R03", lote: "L3", dia: 1, kilos: 80, verdes: 0.5},
      %{recolector: "R04", lote: "L2", dia: 1, kilos: 45, verdes: 8},
      %{recolector: "R05", lote: "L4", dia: 1, kilos: 65, verdes: 2},
      %{recolector: "R06", lote: "L1", dia: 1, kilos: 50, verdes: 12},
      %{recolector: "R07", lote: "L3", dia: 1, kilos: 90, verdes: 1},

      # Día 2
      %{recolector: "R01", lote: "L1", dia: 2, kilos: 90, verdes: 12},
      %{recolector: "R02", lote: "L2", dia: 2, kilos: 130, verdes: 4},
      %{recolector: "R03", lote: "L4", dia: 2, kilos: 40, verdes: 2},
      %{recolector: "R04", lote: "L1", dia: 2, kilos: 75, verdes: 7},
      %{recolector: "R05", lote: "L3", dia: 2, kilos: 55, verdes: 0},
      %{recolector: "R08", lote: "L2", dia: 2, kilos: 100, verdes: 3},
      %{recolector: "R09", lote: "L4", dia: 2, kilos: 60, verdes: 5},

      # Día 3
      %{recolector: "R01", lote: "L2", dia: 3, kilos: 100, verdes: 4},
      %{recolector: "R02", lote: "L3", dia: 3, kilos: 85, verdes: 9},
      %{recolector: "R03", lote: "L1", dia: 3, kilos: 70, verdes: 1},
      %{recolector: "R06", lote: "L4", dia: 3, kilos: 95, verdes: 6},
      %{recolector: "R07", lote: "L1", dia: 3, kilos: 60, verdes: 2},
      %{recolector: "R10", lote: "L2", dia: 3, kilos: 120, verdes: 3.5},

      # Día 4
      %{recolector: "R01", lote: "L3", dia: 4, kilos: 80, verdes: 5},
      %{recolector: "R02", lote: "L1", dia: 4, kilos: 45, verdes: 11},
      %{recolector: "R04", lote: "L4", dia: 4, kilos: 65, verdes: 2},
      %{recolector: "R05", lote: "L2", dia: 4, kilos: 70, verdes: 0},
      %{recolector: "R08", lote: "L3", dia: 4, kilos: 55, verdes: 6},
      %{recolector: "R09", lote: "L1", dia: 4, kilos: 60, verdes: 10.5},

      # Día 5
      %{recolector: "R01", lote: "L4", dia: 5, kilos: 50, verdes: 3},
      %{recolector: "R03", lote: "L2", dia: 5, kilos: 85, verdes: 7},
      %{recolector: "R05", lote: "L1", dia: 5, kilos: 60, verdes: 1},
      %{recolector: "R06", lote: "L3", dia: 5, kilos: 75, verdes: 4},
      %{recolector: "R07", lote: "L2", dia: 5, kilos: 65, verdes: 9},
      %{recolector: "R10", lote: "L4", dia: 5, kilos: 55, verdes: 2},

      # Día 6
      %{recolector: "R01", lote: "L1", dia: 6, kilos: 40, verdes: 1},
      %{recolector: "R02", lote: "L4", dia: 6, kilos: 70, verdes: 6},
      %{recolector: "R04", lote: "L3", dia: 6, kilos: 60, verdes: 3},
      %{recolector: "R07", lote: "L1", dia: 6, kilos: 50, verdes: 10},
      %{recolector: "R08", lote: "L2", dia: 6, kilos: 85, verdes: 0},

      # --- Pesajes válidos adicionales, para llegar a los 80 exigidos ---

      # Día 1
      %{recolector: "R08", lote: "L4", dia: 1, kilos: 60, verdes: 2},
      %{recolector: "R09", lote: "L1", dia: 1, kilos: 55, verdes: 7},
      %{recolector: "R10", lote: "L3", dia: 1, kilos: 95, verdes: 3},
      %{recolector: "R03", lote: "L2", dia: 1, kilos: 40, verdes: 9},
      %{recolector: "R06", lote: "L4", dia: 1, kilos: 65, verdes: 1},

      # Día 2
      %{recolector: "R07", lote: "L1", dia: 2, kilos: 50, verdes: 6},
      %{recolector: "R10", lote: "L2", dia: 2, kilos: 80, verdes: 2},
      %{recolector: "R06", lote: "L3", dia: 2, kilos: 45, verdes: 4},
      %{recolector: "R01", lote: "L4", dia: 2, kilos: 35, verdes: 8},
      %{recolector: "R03", lote: "L1", dia: 2, kilos: 60, verdes: 1},

      # Día 3
      %{recolector: "R04", lote: "L3", dia: 3, kilos: 70, verdes: 5},
      %{recolector: "R05", lote: "L4", dia: 3, kilos: 55, verdes: 2},
      %{recolector: "R08", lote: "L1", dia: 3, kilos: 90, verdes: 0},
      %{recolector: "R09", lote: "L2", dia: 3, kilos: 65, verdes: 3},
      %{recolector: "R02", lote: "L4", dia: 3, kilos: 50, verdes: 10},

      # Día 4
      %{recolector: "R06", lote: "L1", dia: 4, kilos: 75, verdes: 1},
      %{recolector: "R07", lote: "L2", dia: 4, kilos: 60, verdes: 6},
      %{recolector: "R10", lote: "L3", dia: 4, kilos: 85, verdes: 4},
      %{recolector: "R03", lote: "L4", dia: 4, kilos: 45, verdes: 2},
      %{recolector: "R02", lote: "L1", dia: 4, kilos: 55, verdes: 9},

      # Día 5
      %{recolector: "R02", lote: "L3", dia: 5, kilos: 70, verdes: 3},
      %{recolector: "R04", lote: "L2", dia: 5, kilos: 60, verdes: 1},
      %{recolector: "R08", lote: "L4", dia: 5, kilos: 50, verdes: 5},
      %{recolector: "R09", lote: "L1", dia: 5, kilos: 65, verdes: 2},
      %{recolector: "R01", lote: "L2", dia: 5, kilos: 45, verdes: 6},

      # Día 6
      %{recolector: "R03", lote: "L3", dia: 6, kilos: 55, verdes: 2},
      %{recolector: "R05", lote: "L1", dia: 6, kilos: 60, verdes: 4},
      %{recolector: "R06", lote: "L1", dia: 6, kilos: 40, verdes: 1},
      %{recolector: "R09", lote: "L4", dia: 6, kilos: 70, verdes: 3},
      %{recolector: "R10", lote: "L2", dia: 6, kilos: 65, verdes: 5},

      # --- Pesajes válidos, tercera tanda, para superar los 80 exigidos ---

      %{recolector: "R05", lote: "L3", dia: 1, kilos: 50, verdes: 4},
      %{recolector: "R04", lote: "L1", dia: 1, kilos: 45, verdes: 6},
      %{recolector: "R09", lote: "L1", dia: 2, kilos: 60, verdes: 1},
      %{recolector: "R05", lote: "L2", dia: 2, kilos: 40, verdes: 5},
      %{recolector: "R07", lote: "L4", dia: 3, kilos: 55, verdes: 7},
      %{recolector: "R01", lote: "L3", dia: 3, kilos: 50, verdes: 2},
      %{recolector: "R08", lote: "L3", dia: 4, kilos: 65, verdes: 3},
      %{recolector: "R09", lote: "L4", dia: 4, kilos: 40, verdes: 8},
      %{recolector: "R03", lote: "L2", dia: 5, kilos: 55, verdes: 6},
      %{recolector: "R10", lote: "L4", dia: 5, kilos: 45, verdes: 2},
      %{recolector: "R02", lote: "L2", dia: 6, kilos: 60, verdes: 4},
      %{recolector: "R04", lote: "L4", dia: 6, kilos: 50, verdes: 1},

      # --- Pesajes inválidos: al menos dos por cada motivo de rechazo ---

      # :recolector_desconocido
      %{recolector: "R99", lote: "L1", dia: 1, kilos: 50, verdes: 2},
      %{recolector: "R98", lote: "L2", dia: 2, kilos: 40, verdes: 3},

      # :lote_desconocido
      %{recolector: "R01", lote: "L9", dia: 1, kilos: 45, verdes: 2},
      %{recolector: "R02", lote: "L8", dia: 3, kilos: 55, verdes: 4},

      # :dia_invalido
      %{recolector: "R03", lote: "L1", dia: 0, kilos: 60, verdes: 2},
      %{recolector: "R04", lote: "L2", dia: 7, kilos: 50, verdes: 3},

      # :kilos_fuera_de_rango (menor o igual a 0, mayor a 250, o no numérico)
      %{recolector: "R05", lote: "L1", dia: 2, kilos: 0, verdes: 2},
      %{recolector: "R06", lote: "L2", dia: 3, kilos: 300, verdes: 3},
      %{recolector: "R07", lote: "L3", dia: 4, kilos: "cincuenta", verdes: 2},

      # :porcentaje_invalido (fuera de 0 a 100, o no numérico)
      %{recolector: "R08", lote: "L1", dia: 5, kilos: 60, verdes: -1},
      %{recolector: "R09", lote: "L2", dia: 6, kilos: 55, verdes: 120},
      %{recolector: "R10", lote: "L3", dia: 1, kilos: 50, verdes: "alto"}
    ]
  end
end
