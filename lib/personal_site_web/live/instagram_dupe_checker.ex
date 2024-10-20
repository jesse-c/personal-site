defmodule PersonalSiteWeb.Live.InstagramDupeChecker do
  @moduledoc """
  The app page for the Instagram dupe checker.
  """

  use PersonalSiteWeb, :live_view

  defmodule PredictionClient do
    @moduledoc """
    The prediction client for the service.
    """

    use Tesla

    plug Tesla.Middleware.Logger

    adapter(Tesla.Adapter.Hackney,
      transport_opts: [
        inet6: true
      ]
    )

    def get_similar_images(image_path) do
      url = Application.get_env(:personal_site, PersonalSite.InstagramDupeChecker)[:url]
      port = Application.get_env(:personal_site, PersonalSite.InstagramDupeChecker)[:port]
      endpoint = "http://#{url}:#{port}/predict"

      IO.puts("Sending request to #{endpoint}")
      IO.puts("File: #{Path.basename(image_path)}")

      {:ok, image_data} = File.read(image_path)

      filename = Path.basename(image_path)

      mp =
        Tesla.Multipart.add_file_content(Tesla.Multipart.new(), image_data, filename,
          name: "image"
        )

      case post(endpoint, mp) do
        {:ok, %{status: 200, body: body}} ->
          case Jason.decode(body) do
            {:ok, %{"similar_images" => similar_images}} ->
              {:ok, similar_images}

            {:error, _} ->
              {:error, "Failed to parse response JSON"}
          end

        {:ok, %{status: status}} ->
          {:error, "Request failed with status #{status}"}

        {:error, error} ->
          {:error, "Request failed: #{inspect(error)}"}
      end
    end
  end

  def inner_mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:response, nil)
      |> assign(page_title: "Instagram Dupe Checker")
      |> allow_upload(
        :candidate,
        accept: ~w(.jpg .jpeg),
        max_entries: 1,
        max_file_size: 12_000_000
      )
    }
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <div class="space-y-3">
      <h1 class="text-lg">Instagram dupe checker</h1>
      <p class="text-sm">
        Upload an image to find the likelihood of me having a posted a picture like this, including similar photos.
      </p>
      <div class="lg:w-1/2 font-normal mb-8 p-3 rounded-sm border border-black dark:border-white">
        <form id="upload-form" phx-submit="save" phx-change="validate" class="space-y-3">
          <.live_file_input upload={@uploads.candidate} class="rounded-sm text-sm block" />
          <button
            type="submit"
            class="border border-solid rounded-sm border-black dark:border-white hover:bg-black dark:hover:bg-white text-black dark:text-white hover:text-white dark:hover:text-black transition-colors p-2 mb-6 text-xs max-w-fit"
          >
            Upload
          </button>
        </form>
      </div>
      <%= if @response do %>
        <h2 class="text-md">Results</h2>
        <%= case @response do %>
          <% [{:ok, similar_images}] -> %>
            <div class="gap-3 text-sm flex flex-col md:flex-row">
              <%= for image <- similar_images do %>
                <div class="w-full lg:w-1/5 p-3 rounded-sm border border-dashed border-black dark:border-white space-y-3">
                  <span>
                    #<%= image["rank"] %> at <%= Float.round(image["similarity_percentage"], 2) %>%
                  </span>
                  <img src={"data:image/jpeg;base64,#{image["image_base64"]}"} class="object-contain" />
                </div>
              <% end %>
            </div>
          <% [{:error, message}] -> %>
            <p class="alert alert-danger">Error: <%= message %></p>
        <% end %>
      <% end %>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :candidate, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    if match?(
         {:deny, _limit},
         Hammer.check_rate("save:#{socket.assigns[:client_ip]}", 60_000, 10)
       ) do
      socket =
        socket
        |> clear_flash()
        |> put_flash(:error, "Try again later!")

      {:noreply, socket}
    else
      response =
        consume_uploaded_entries(socket, :candidate, fn %{path: image_path}, _entry ->
          response = PredictionClient.get_similar_images(image_path)

          print_prediction(response)

          File.rm(image_path)

          {:ok, response}
        end)

      {:noreply, assign(socket, :response, response)}
    end
  end

  defp print_prediction(response)

  defp print_prediction({:ok, similar_images}) do
    IO.puts("Successfully retrieved similar images:")

    Enum.each(similar_images, fn image ->
      IO.puts("Rank: #{image["rank"]}")
      IO.puts("Filename: #{image["filename"]}")
      IO.puts("Similarity: #{image["similarity_percentage"]}%")
      IO.puts("Base64: #{String.slice(image["image_base64"], 0, 10)}")
      IO.puts("---")
    end)
  end

  defp print_prediction({:error, message}) do
    IO.puts("Error: #{message}")
  end
end
