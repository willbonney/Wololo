defmodule WololoWeb.CivsByMapLive do
  use WololoWeb, :live_view
  alias Wololo.CivsByMapAPI
  require Logger
  import WololoWeb.Components.Spinner

  @league_options [
    {"Bronze", "bronze"},
    {"Silver", "silver"},
    {"Gold", "gold"},
    {"Platinum", "platinum"},
    {"Diamond", "diamond"},
    {"Conqueror", "conqueror"},
    {"> Platinum", "≥platinum"},
    {">Diamond", "≥diamond"},
    {">Conq 1", "≥conqueror_1"},
    {">Conq 2", "≥conqueror_2"},
    {">Conq3", "≥conqueror_3"},
    {">Conq4", "≥conqueror_4"}
  ]

  @civs [
    %{key: :name, label: "Map", image: nil},
    %{key: :abbasid_dynasty, label: "Abbasid Dynasty", image: "abbasid_dynasty"},
    %{key: :chinese, label: "Chinese", image: "chinese"},
    %{key: :delhi_sultanate, label: "Delhi Sultanate", image: "delhi_sultanate"},
    %{key: :english, label: "English", image: "english"},
    %{key: :french, label: "French", image: "french"},
    %{key: :holy_roman_empire, label: "Holy Roman Empire", image: "holy_roman_empire"},
    %{key: :mongols, label: "Mongols", image: "mongols"},
    %{key: :rus, label: "Rus", image: "rus"},
    %{key: :ottomans, label: "Ottomans", image: "ottomans"},
    %{key: :malians, label: "Malians", image: "malians"},
    %{key: :byzantines, label: "Byzantines", image: "byzantines"},
    %{key: :japanese, label: "Japanese", image: "japanese"},
    %{key: :ayyubids, label: "Ayyubids", image: "ayyubids"},
    %{key: :jeanne_darc, label: "Jeanne d'Arc", image: "jeanne_darc"},
    %{key: :order_of_the_dragon, label: "Order of the Dragon", image: "order_of_the_dragon"},
    %{key: :zhu_xis_legacy, label: "Zhu Xi's Legacy", image: "zhu_xis_legacy"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        maps: [],
        civs: @civs,
        league_options: @league_options,
        selected_league: nil,
        loading: true,
        error: nil
      )

    if connected?(socket) do
      send(self(), :fetch_initial_data)
    end

    {:ok, socket}
  end

  @impl true
  def handle_event("select-league", %{"league" => league}, socket) do
    socket =
      socket
      |> assign(loading: true, selected_league: league, error: nil)
      |> fetch_civs_data(league)

    {:noreply, socket}
  end

  @impl true
  @spec handle_info(:fetch_initial_data, any()) :: {:noreply, any()}
  def handle_info(:fetch_initial_data, socket) do
    {:noreply, fetch_civs_data(socket)}
  end

  defp fetch_civs_data(socket, league \\ nil) do
    case CivsByMapAPI.fetch_civs_by_map(league) do
      {:ok, raw_data} ->
        transformed_data = CivsByMapAPI.transform_data(raw_data)
        assign(socket, maps: transformed_data, loading: false, error: nil)

      {:error, reason} ->
        assign(socket, maps: [], loading: false, error: "Failed to fetch Civs By Map: #{reason}")
    end
  end

  def civ_header(assigns) do
    ~H"""
    <div class="flex items-center flex-col">
      <%= if @image do %>
        <img src={"/images/#{@image}.png"} alt={@label} class="w-10 h-6 mr-2" />
      <% end %>
      <span><%= @label %></span>
    </div>
    """
  end

  def color_class(percentage, type) when is_binary(percentage) do
    case Float.parse(percentage) do
      {value, "%"} -> color_class(value, type)
      # Default color for invalid input
      _ -> "bg-gray-100"
    end
  end

  def color_class(percentage, type) when is_number(percentage) and type in [:bg, :text] do
    prefix = if type == :bg, do: "bg", else: "text"

    # remember to safelist these classes in tailwind.config.js!
    cond do
      percentage < 45 -> "#{prefix}-red-500"
      percentage < 47 -> "#{prefix}-red-400"
      percentage < 49 -> "#{prefix}-red-300"
      percentage < 50 -> "#{prefix}-red-200"
      percentage == 50 -> "#{prefix}-gray-200"
      percentage < 51 -> "#{prefix}-green-200"
      percentage < 53 -> "#{prefix}-green-300"
      percentage < 55 -> "#{prefix}-green-400"
      true -> "#{prefix}-gray-500"
    end
  end

  def color_class(_, type) when type in [:bg, :text] do
    if type == :bg, do: "bg-gray-100", else: "text-gray-600"
  end
end