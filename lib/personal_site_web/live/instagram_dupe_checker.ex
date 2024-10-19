defmodule PersonalSiteWeb.Live.InstagramDupeChecker do
  use PersonalSiteWeb, :live_view

  defmodule PredictionClient do
    use Tesla

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
      |> allow_upload(:candidate,
        accept: ~w(.jpg .jpeg),
        max_entries: 1,
        max_file_size: 12_000_000
      )
    }
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PersonalSiteWeb.Live.Cursors} id="cursors" users={@users} />
    <div>
      <h1>Instagram dupe checker</h1>
      <%= if @response do %>
        <hr />
        <section class="results">
          <h2>Results</h2>
          <%= case @response do %>
            <% [{:ok, similar_images}] -> %>
              <ul>
                <%= for image <- similar_images do %>
                  <li>
                    <p>Rank: <%= image["rank"] %></p>
                    <p>Filename: <%= image["filename"] %></p>
                    <p>Similarity: <%= Float.round(image["similarity_percentage"], 2) %>%</p>
                  </li>
                <% end %>
              </ul>
            <% [{:error, message}] -> %>
              <p class="alert alert-danger">Error: <%= message %></p>
          <% end %>
        </section>
        <hr />
      <% end %>
    </div>
    <form id="upload-form" phx-submit="save" phx-change="validate">
      <.live_file_input upload={@uploads.candidate} />
      <button type="submit">Upload</button>
    </form>

    <section phx-drop-target={@uploads.candidate.ref}>
      <%= for entry <- @uploads.candidate.entries do %>
        <article class="upload-entry">
          <figure>
            <.live_img_preview entry={entry} />
            <figcaption><%= entry.client_name %></figcaption>
          </figure>

          <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>

          <button
            type="button"
            phx-click="cancel-upload"
            phx-value-ref={entry.ref}
            aria-label="cancel"
          >
            &times;
          </button>

          <%= for err <- upload_errors(@uploads.candidate, entry) do %>
            <p class="alert alert-danger"><%= error_to_string(err) %></p>
          <% end %>
        </article>
      <% end %>

      <%= for err <- upload_errors(@uploads.candidate) do %>
        <p class="alert alert-danger"><%= error_to_string(err) %></p>
      <% end %>
    </section>
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
        consume_uploaded_entries(socket, :candidate, fn %{path: image_path}, entry ->
          # # Example
          #
          # ## Path
          #
          # "/var/folders/sn/jwxlp9dd6d315j7rmblgr37m0000gn/T/plug-1729-TfDS/live_view_upload-1729374153-244860115245-2"
          #
          # ## Entry
          #
          # %Phoenix.LiveView.UploadEntry{
          #   progress: 100,
          #   preflighted?: true,
          #   upload_config: :candidate,
          #   upload_ref: "phx-F__4n6yZa_rYt0rC",
          #   ref: "0",
          #   uuid: "644e11e3-59fe-4472-8ea5-ef81c058c715",
          #   valid?: true,
          #   done?: true,
          #   cancelled?: false,
          #   client_name: "DSC01605.jpeg",
          #   client_relative_path: "",
          #   client_size: 11571188,
          #   client_type: "image/jpeg",
          #   client_last_modified: 1729030404000,
          #   client_meta: nil
          # }

          response = PredictionClient.get_similar_images(image_path)

          case response do
            {:ok, similar_images} ->
              IO.puts("Successfully retrieved similar images:")

              Enum.each(similar_images, fn image ->
                IO.puts("Rank: #{image["rank"]}")
                IO.puts("Filename: #{image["filename"]}")
                IO.puts("Similarity: #{image["similarity_percentage"]}%")
                IO.puts("---")
              end)

            {:error, message} ->
              IO.puts("Error: #{message}")
          end

          File.rm(image_path)

          {:ok, response}
        end)

      {:noreply, assign(socket, :response, response)}
    end
  end

  defp error_to_string(error)
  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
