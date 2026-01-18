defmodule SMWCBotHackTest do
  use ExUnit.Case, async: true
  use Mimic

  import ExUnit.CaptureLog

  alias SMWC.JSONResponses
  alias SMWCBot.MessageServer

  describe "Hack search" do
    test "returns first result to user with 0 results" do
      chat = "mychat"
      sender = "user-mcface"

      expected_message = "Sorry #{sender}, no results"

      expect(Req, :get, fn _uri ->
        json = %{"data" => [], "total" => 0, "per_page" => 50}
        {:ok, %{status: 200, body: Jason.encode!(json)}}
      end)

      expect(MessageServer, :add_message, fn actual_chat, actual_message ->
        assert actual_chat == chat
        assert actual_message == expected_message
        :ok
      end)

      assert :ok = SMWCBot.handle_message("!hack what the eff", sender, chat)
    end

    test "returns first result to user with 1 result" do
      chat = "mychat"
      sender = "user-mcface"

      expected_text = "Tis A Silly Place"
      expected_id = 41390
      expected_href = "https://www.smwcentral.net/?p=section&a=details&id=#{expected_id}"
      expected_message = "#{sender}, #{expected_text} @ #{expected_href}"

      expect(Req, :get, fn _uri ->
        {:ok, %{status: 200, body: Jason.encode!(JSONResponses.single_result())}}
      end)

      expect(MessageServer, :add_message, fn actual_chat, actual_message ->
        assert actual_chat == chat
        assert actual_message == expected_message
        :ok
      end)

      assert :ok = SMWCBot.handle_message("!hack silly", sender, chat)
    end

    test "returns first result to user with 2 results" do
      chat = "mychat"
      sender = "user-mcface"

      json = %{
        "data" => [
          %{"id" => 1, "name" => "First Result"},
          %{"id" => 2, "name" => "Second Result"}
        ],
        "total" => 2,
        "per_page" => 50
      }

      expected_href = "https://www.smwcentral.net/?p=section&s=smwhacks&f%5Bname%5D=foo&o=date&d=desc"
      expected_message = "#{sender}, I found multiple results @ #{expected_href}"

      expect(Req, :get, fn _uri ->
        {:ok, %{status: 200, body: Jason.encode!(json)}}
      end)

      expect(MessageServer, :add_message, fn actual_chat, actual_message ->
        assert actual_chat == chat
        assert actual_message == expected_message
        :ok
      end)

      assert :ok = SMWCBot.handle_message("!hack foo", sender, chat)
    end

    test "returns first result to user with multiple pages" do
      chat = "mychat"
      sender = "user-mcface"

      expected_href = "https://www.smwcentral.net/?p=section&s=smwhacks&f%5Bname%5D=mario&o=date&d=desc"
      expected_message = "#{sender}, I found multiple results @ #{expected_href}"

      expect(Req, :get, fn _uri ->
        {:ok, %{status: 200, body: Jason.encode!(JSONResponses.multiple_results())}}
      end)

      expect(MessageServer, :add_message, fn actual_chat, actual_message ->
        assert actual_chat == chat
        assert actual_message == expected_message
        :ok
      end)

      assert :ok = SMWCBot.handle_message("!hack mario", sender, chat)
    end

    test "returns first result with --first flag" do
      chat = "mychat"
      sender = "user-mcface"

      expected_text = "MARIO EN BUSCA DE LA MASTER EMERALD (DEMO WORLD 2)"
      expected_id = 41397
      expected_href = "https://www.smwcentral.net/?p=section&a=details&id=#{expected_id}"
      expected_message = "#{sender}, #{expected_text} @ #{expected_href}"

      expect(Req, :get, fn _uri ->
        {:ok, %{status: 200, body: Jason.encode!(JSONResponses.multiple_results())}}
      end)

      expect(MessageServer, :add_message, fn actual_chat, actual_message ->
        assert actual_chat == chat
        assert actual_message == expected_message
        :ok
      end)

      assert :ok = SMWCBot.handle_message("!hack -f mario", sender, chat)
    end

    test "returns error when smwcentral.net returns a non-200 status code" do
      chat = "mychat"
      sender = "user-mcface"
      status_code = 404
      body = "Not found"

      expected_message = "Sorry #{sender}, bot can't complete that search: #{status_code}"

      expect(Req, :get, fn _uri ->
        {:ok, %{status: status_code, body: body}}
      end)

      expect(MessageServer, :add_message, fn actual_chat, actual_message ->
        assert actual_chat == chat
        assert actual_message == expected_message
        :ok
      end)

      log =
        capture_log(fn ->
          assert :ok = SMWCBot.handle_message("!hack mario", sender, chat)
        end)

      assert log =~ "Error fetching page, status #{status_code}: \"#{body}\""
    end

    test "returns error when Req returns an error" do
      chat = "mychat"
      sender = "user-mcface"
      error = "This is error"

      expected_message = "Sorry #{sender}, bot can't complete that search: #{inspect(error)}"

      expect(Req, :get, fn _uri ->
        {:error, error}
      end)

      expect(MessageServer, :add_message, fn actual_chat, actual_message ->
        assert actual_chat == chat
        assert actual_message == expected_message
        :ok
      end)

      log =
        capture_log(fn ->
          assert :ok = SMWCBot.handle_message("!hack mario", sender, chat)
        end)

      assert log =~ "Error fetching page: #{inspect(error)}"
    end
  end
end
