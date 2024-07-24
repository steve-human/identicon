defmodule Identicon do
  alias Image, as: Img

  def main do
    input = IO.gets("Enter input string: ") |> String.trim()

    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)

    IO.puts("Identicon saved as #{input}.png")
  end

  def save_image(image, input) do
    Image.write!(image, "#{input}.png")
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    {:ok, image} = Image.new(250, 250, color: [255, 255, 255])

    {:ok, image} =
      Enum.reduce(pixel_map, {:ok, image}, fn {{x1, y1}, {x2, y2}}, {:ok, img} ->
        Img.mutate(img, fn mut_img ->
          Img.Draw.rect(mut_img, x1, y1, x2 - x1 + 1, y2 - y1 + 1, color: color)
        end)
      end)

    image
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      grid
      |> Enum.map(fn {_code, index} ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50

        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}

        {top_left, bottom_right}
      end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    filtered_grid =
      grid
      |> Enum.filter(fn {code, _index} -> rem(code, 2) == 0 end)

    %Identicon.Image{image | grid: filtered_grid}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.flat_map(&mirror_row/1)
      |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
  end

  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Identicon.Image{hex: hex}
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _]} = image) do
    %Identicon.Image{image | color: [r, g, b]}
  end
end
