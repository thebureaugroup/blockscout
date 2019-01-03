defmodule Explorer.Validator.MetadataRetrieverTest do
  use EthereumJSONRPC.Case

  alias Explorer.Validator.MetadataRetriever
  import Mox

  setup :verify_on_exit!
  setup :set_mox_global

  describe "fetch_data/0" do
    test "returns maps with the info on each validator" do
      validators_list_mox_ok()
      validator_metadata_mox_ok()

      expected = [
        %{
          address_hash: <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1>>,
          name: "Testname Unitarion",
          primary: true,
          metadata: %{
            address: "",
            created_date: 0,
            expiration_date: 253_370_764_800,
            license_id: "00000000",
            state: "XX",
            zipcode: "00000"
          }
        }
      ]

      assert MetadataRetriever.fetch_data() == expected
    end

    test "raise error when the first contract call fails" do
      contract_request_with_error("getValidators")
      assert_raise(MatchError, fn -> MetadataRetriever.fetch_data() end)
    end

    test "raise error when a call to the metadatc contract fails" do
      validators_list_mox_ok()
      contract_request_with_error("validators")
      assert_raise(MatchError, fn -> MetadataRetriever.fetch_data() end)
    end
  end

  defp contract_request_with_error(id) do
    expect(
      EthereumJSONRPC.Mox,
      :json_rpc,
      fn [%{id: ^id, method: _, params: _}], _options ->
        {:ok,
         [
           %{
             error: %{code: -32015, data: "Reverted 0x", message: "VM execution error."},
             id: id,
             jsonrpc: "2.0"
           }
         ]}
      end
    )
  end

  defp validators_list_mox_ok() do
    expect(
      EthereumJSONRPC.Mox,
      :json_rpc,
      1,
      fn [%{id: "getValidators"}], _opts ->
        {:ok,
         [
           %{
             id: "getValidators",
             jsonrpc: "2.0",
             result:
               "0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001"
           }
         ]}
      end
    )
  end

  defp validator_metadata_mox_ok() do
    expect(
      EthereumJSONRPC.Mox,
      :json_rpc,
      1,
      fn [%{id: "validators"}], _opts ->
        {:ok,
         [
           %{
             id: "validators",
             jsonrpc: "2.0",
             result:
               "0x546573746e616d65000000000000000000000000000000000000000000000000556e69746172696f6e000000000000000000000000000000000000000000000030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000140585800000000000000000000000000000000000000000000000000000000000030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003afe130e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000058585858585858207374726565742058585858585800000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
           }
         ]}
      end
    )
  end
end
