defmodule Sitemap.Generator do
  alias Sitemap.{Namer, Location, Builders.Indexfile}
  alias Sitemap.Builders.File, as: FileBuilder

  def add(links, attrs \\ []) do
    Map.each(links, fn link ->
      case FileBuilder.add(link, attrs) do
        :ok   -> :ok
        :full ->
          full()
          add(links, attrs)
      end
    end)
  end

  def add_to_index(link, options \\ []) do
    Indexfile.add link, options
  end

  def full do
    Indexfile.add
    FileBuilder.finalize_state
  end

  def fin do
    full()
    reset()
  end

  def reset do
    Indexfile.write
    Indexfile.finalize_state
    Namer.update_state :file, :count, nil
  end

  # def group do end

  def ping(urls \\ []) do
    urls = ~w(http://google.com/ping?sitemap=%s
              http://www.bing.com/webmaster/ping.aspx?sitemap=%s) ++ urls

    indexurl = Location.url :indexfile

    spawn fn ->
      Enum.each urls, fn url ->
        ping_url = String.replace(url, "%s", indexurl)

        :httpc.request('#{ping_url}')
        IO.puts "Successful ping of #{ping_url}"
      end
    end
  end

end
