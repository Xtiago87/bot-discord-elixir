defmodule Anibot.Consumer do
  use Nostrum.Consumer
  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    cond do
      String.starts_with?(msg.content, "!search_manga") ->
        searchManga(msg)

      String.starts_with?(msg.content, "!search_anime") ->
        searchAnime(msg)

      String.starts_with?(msg.content, "!character_quote") ->
        evaluate_character_quote(msg)

      String.starts_with?(msg.content, "!anime_curiosity") ->
        animeCuriosity(msg)

      String.starts_with?(msg.content, "!pokemon_card") ->
        searchPokemonCard(msg)

      String.starts_with?(msg.content, "!help") ->
        Api.create_message(
          msg.channel_id,
          "Comandos disponiveis: \n !search_anime nome do anime \n !fact nome do anime \n !character_quote nome do anime \n !pokemon_card nome do pokemon\n !search_manga nome do mangá"
        )

      String.starts_with?(msg.content, "!") ->
        Api.create_message(
          msg.channel_id,
          "Comando indisponivel. Comandos disponiveis: \n !search_anime nome do anime \n !fact nome do anime \n !character_quote nome do anime \n !pokemon_card nome do pokemon\n !search_manga nome do mangá"
        )

      true ->
        :ok
    end
  end

  def handle_event(_) do
    :ok
  end

  defp evaluate_character_quote(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    characterName = Enum.fetch!(aux, 1)

    url = "https://animechan.vercel.app/api/quotes/character?name=#{characterName}"

    response = HTTPoison.get!(url)

    case response.status_code do
      200 ->
        json = Poison.decode!(response.body)

        nome = Enum.map(json, fn animes -> animes["anime"] end)
        personagem = Enum.map(json, fn animes -> animes["character"] end)
        quote_ = Enum.map(json, fn animes -> animes["quote"] end)

        nome_first = Enum.at(nome, 0)
        personagem_first = Enum.at(personagem, 0)
        rng = Enum.random(0..9)
        quote_first = Enum.at(quote_, rng)

        Api.create_message(
          msg.channel_id,
          " **Nome do anime**: #{nome_first} \n **Personagem**: #{personagem_first} \n **Quote**: #{quote_first}"
        )

      404 ->
        Api.create_message(
          msg.channel_id,
          "Não achamos nenhuma frase dita por esse personagem."
        )

      _ ->
        Api.create_message(msg.channel_id, "Erro ao se comunicar com a API")
    end
  end

  defp animeCuriosity(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    animeName = Enum.fetch!(aux, 1)

    url =
      "https://anime-facts-rest-api.herokuapp.com/api/v1/#{String.replace(animeName, " ", "_")}"

    response = HTTPoison.get!(url)

    case response.status_code do
      200 ->
        json = Poison.decode!(response.body)

        data = json["data"]
        img = json["img"]
        totalFacts = json["total_facts"]

        fact = Enum.map(data, fn dataMap -> dataMap["fact"] end)

        rng = Enum.random(0..totalFacts)
        quote_first = Enum.at(fact, rng)

        Api.create_message(
          msg.channel_id,
          " **Nome do anime**: #{animeName} \n **Curiosidade**: #{quote_first}"
        )

        Api.create_message(
          msg.channel_id,
          "#{img}"
        )

      400 ->
        Api.create_message(
          msg.channel_id,
          "Não achamos nenhum anime com esse nome."
        )

      _ ->
        Api.create_message(msg.channel_id, "Erro ao se comunicar com a API")
    end
  end

  defp searchManga(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    mangaName = Enum.fetch!(aux, 1)

    if String.length(mangaName) >= 3 do
      url = "https://api.jikan.moe/v3/search/manga?q=#{mangaName}"

      response = HTTPoison.get!(url)

      case response.status_code do
        200 ->
          json = Poison.decode!(response.body)

          data = json["results"]

          title = Enum.map(data, fn dataMap -> dataMap["title"] end)
          chapters = Enum.map(data, fn dataMap -> dataMap["chapters"] end)
          description = Enum.map(data, fn dataMap -> dataMap["synopsis"] end)
          nota = Enum.map(data, fn dataMap -> dataMap["score"] end)
          image = Enum.map(data, fn dataMap -> dataMap["image_url"] end)

          title_first = Enum.at(title, 0)
          chapters_first = Enum.at(chapters, 0)
          nota_first = Enum.at(nota, 0)
          description_first = Enum.at(description, 0)
          image_first = Enum.at(image, 0)

          Api.create_message(
            msg.channel_id,
            "**Nome**: #{title_first} \n **Numero de capítulos**: #{chapters_first} \n **Descricao**: #{description_first} \n **Nota**: #{nota_first}/10"
          )

          Api.create_message(
            msg.channel_id,
            "#{image_first} "
          )

        404 ->
          Api.create_message(
            msg.channel_id,
            "Não achamos nenhum mangá com esse nome."
          )

        _ ->
          Api.create_message(msg.channel_id, "Erro ao se comunicar com a API")
      end
    else
      Api.create_message(
        msg.channel_id,
        "Nome do mangá precisa ter pelo menos 3 letras"
      )
    end
  end

  defp searchAnime(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    animeName = Enum.fetch!(aux, 1)

    if String.length(animeName) >= 3 do
      url = "https://api.jikan.moe/v3/search/anime?q=#{animeName}"

      response = HTTPoison.get!(url)

      case response.status_code do
        200 ->
          json = Poison.decode!(response.body)

          data = json["results"]

          title = Enum.map(data, fn dataMap -> dataMap["title"] end)
          eps = Enum.map(data, fn dataMap -> dataMap["episodes"] end)
          description = Enum.map(data, fn dataMap -> dataMap["synopsis"] end)
          nota = Enum.map(data, fn dataMap -> dataMap["score"] end)
          image = Enum.map(data, fn dataMap -> dataMap["image_url"] end)

          title_first = Enum.at(title, 0)
          eps_first = Enum.at(eps, 0)
          nota_first = Enum.at(nota, 0)
          description_first = Enum.at(description, 0)
          image_first = Enum.at(image, 0)

          Api.create_message(
            msg.channel_id,
            "**Nome**: #{title_first} \n **Numero de eps**: #{eps_first} \n **Descricao**: #{description_first} \n **Nota**: #{nota_first}/10"
          )

          Api.create_message(
            msg.channel_id,
            "#{image_first} "
          )

        404 ->
          Api.create_message(
            msg.channel_id,
            "Não achamos nenhum anime com esse nome."
          )

        _ ->
          Api.create_message(msg.channel_id, "Erro ao se comunicar com a API")
      end
    else
      Api.create_message(
        msg.channel_id,
        "Nome do anime precisa ter pelo menos 3 letras"
      )
    end
  end

  defp searchPokemonCard(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    pokemonName = Enum.fetch!(aux, 1)

    url = "https://api.pokemontcg.io/v2/cards?q=name:#{pokemonName}"
    # gyazo
    # sharex
    # liteshot
    response = HTTPoison.get!(url)

    case response.status_code do
      200 ->
        json = Poison.decode!(response.body)

        data = json["data"]

        if length(data) == 0 do
          Api.create_message(
            msg.channel_id,
            "Não achamos nenhum pokemon com esse nome"
          )
        else
          title = Enum.map(data, fn dataMap -> dataMap["images"] end)
          title_first = Enum.at(title, 0)

          image = title_first["small"]

          Api.create_message(
            msg.channel_id,
            "#{image}"
          )
        end

      404 ->
        Api.create_message(
          msg.channel_id,
          "Não achamos nenhum pokemon com esse nome"
        )

      _ ->
        Api.create_message(msg.channel_id, "Erro ao se comunicar com a API")
    end
  end
end
