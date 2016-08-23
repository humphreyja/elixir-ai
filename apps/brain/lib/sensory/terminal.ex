defmodule Sensory.Terminal do
  use GenServer

  def start_link(:default) do
    GenServer.start_link(__MODULE__, :ok, %{})
  end

  def init(:ok) do
    # TODO (Sensory): Spawn executable for camera.  Store process in state.
    {:ok, %{}}
  end

  def read(server, data) do
    # TODO (Sensory): Initiate infinate read from camera.
    GenServer.cast(server, {:read, data})
  end

  def handle_cast({:read, data}, state) do
    # TODO: (Sensory): On each message, send image to Thalamus core.
    {:noreply, state}
  end

  def letters do
    {
      a: [1],
      b: [2],
      c: [3],
      d: [4],
      e: [5],
      f: [6],
      g: [7],
      h: [8],
      i: [9],
      j: [10],
      k: [11],
      l: [12],
      m: [13],
      n: [14],
      o: [15],
      p: [16],
      q: [17],
      r: [18],
      s: [19],
      t: [20],
      u: [21],
      v: [22],
      w: [23],
      x: [24],
      y: [25],
      z: [26],
      "!": [27],
      "@": [28],
      "#": [29],
      "$": [30],
      "%": [31],
      "^": [32],
      "&": [33],
      "*": [34],
      "(": [35],
      ")": [36],
      "-": [37],
      "+": [38],
      "_": [39],
      "=": [40],
      "[": [41],
      "]": [42],
      "{": [43],
      "}": [44],
      "?": [45],
      ".": [46],
      ",": [47],
      "<": [48],
      ">": [49],
      "/": [50],
      '"': [51],
      "'": [52],
      "|": [53],
      "\\": [54],
      "`": [55],
      "~": [56],
      "\s": [57],
      "\t": [58],
      "\n": [59],
      "\r": [60],
      "1": [61],
      "2": [62],
      "3": [63],
      "4": [64],
      "5": [65],
      "6": [66],
      "7": [67],
      "8": [68],
      "9": [69],
      "0": [70]
    }
  end
end


a = 1000000001
b = 0100000010
