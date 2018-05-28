import Foundation
@testable import Steem
import XCTest

class BlockTest: XCTestCase {
    func testCodable() throws {
        let block = try TestDecode(SignedBlock.self, json: block2000000)
        XCTAssertEqual(block.num, 2_000_000)
        XCTAssertEqual(block.witness, "steempty")
        XCTAssertEqual(block.witnessSignature, Signature("1f26706cb7da8528a303f55c7e260b8b43ba2aaddb2970d01563f5b1d1dc1d8e0342e4afe22e95277d37b4e7a429df499771f8db064e64aa964a0ba4a17a18fb2b"))
        XCTAssertEqual(block.timestamp, Date(timeIntervalSince1970: 1_464_911_925))
        XCTAssertEqual(block.transactions.count, 3)
        let op = block.transactions.first?.operations.first as? Steem.Operation.Vote
        XCTAssertEqual(op?.voter, "proctologic")
        AssertEncodes(block, [
            "previous": "001e847f77b2d0bc1c29caf02b1a98d79aefb7ad",
            "timestamp": "2016-06-02T23:58:45",
            "witness": "steempty",
            "transaction_merkle_root": "3335e6efe04f09aac61ad1fcc241ada1e1e8fc62",
            "witness_signature": "1f26706cb7da8528a303f55c7e260b8b43ba2aaddb2970d01563f5b1d1dc1d8e0342e4afe22e95277d37b4e7a429df499771f8db064e64aa964a0ba4a17a18fb2b",
        ])
    }
}

fileprivate let block2000000 = """
{
  "previous": "001e847f77b2d0bc1c29caf02b1a98d79aefb7ad",
  "timestamp": "2016-06-02T23:58:45",
  "witness": "steempty",
  "transaction_merkle_root": "3335e6efe04f09aac61ad1fcc241ada1e1e8fc62",
  "extensions": [],
  "witness_signature": "1f26706cb7da8528a303f55c7e260b8b43ba2aaddb2970d01563f5b1d1dc1d8e0342e4afe22e95277d37b4e7a429df499771f8db064e64aa964a0ba4a17a18fb2b",
  "transactions": [
    {
      "ref_block_num": 33918,
      "ref_block_prefix": 2329120500,
      "expiration": "2016-06-02T23:58:54",
      "operations": [
        [
          "vote",
          {
            "voter": "proctologic",
            "author": "pal",
            "permlink": "re-dantheman-re-pal-httpssteemit-comsteempalsniper-whale-vote-bot-strategy-20160602t162811551z",
            "weight": 10000
          }
        ]
      ],
      "extensions": [],
      "signatures": [
        "1f0ad8680045212314210892e338f14bc4fd34b2573e6217591b036be6222c5d980dbc2d3547429924389330e876ab650a1dd9548284d8a855c96b58c542d0a499"
      ],
      "transaction_id": "747e19a0a1511d162dfcb5258f62de520294982b",
      "block_num": 2000000,
      "transaction_num": 0
    },
    {
      "ref_block_num": 33919,
      "ref_block_prefix": 3167793783,
      "expiration": "2016-06-02T23:58:57",
      "operations": [
        [
          "vote",
          {
            "voter": "proctologic",
            "author": "oholiab",
            "permlink": "re-dantheman-re-streemian-re-re-dantheman-lessons-learned-from-curation-rewards-discussion-20160602t150813-20160602t161538485z",
            "weight": 10000
          }
        ]
      ],
      "extensions": [],
      "signatures": [
        "1f45456b18a8df371cb1890f15f4e9a7b59b9759d9982d3e96429343c2899fcda668a295bfd6eaa630785ed807aa93485301723870d6f34769bc25a6fbc91d0253"
      ],
      "transaction_id": "7ed4ca6109927b1593e33525db606e9cf867e4f4",
      "block_num": 2000000,
      "transaction_num": 1
    },
    {
      "ref_block_num": 33919,
      "ref_block_prefix": 3167793783,
      "expiration": "2016-06-02T23:58:57",
      "operations": [
        [
          "vote",
          {
            "voter": "proctologic",
            "author": "abit",
            "permlink": "re-dantheman-lessons-learned-from-curation-rewards-discussion-20160602t160856942z",
            "weight": 10000
          }
        ]
      ],
      "extensions": [],
      "signatures": [
        "1f5fd52ca5c91b118c8ac2f2f6f6df28bc10122baaabbd3f510c37b3201c86a4845419a0d6a17cf267c73d939f1fa7230c7f9f85e60b784e54cf041091d0cbb41f"
      ],
      "transaction_id": "ac7489dbe69ac338cae85824dc58160515095341",
      "block_num": 2000000,
      "transaction_num": 2
    }
  ],
  "block_id": "001e84802fe2d042906f33a9cc4fd49f024c7eb9",
  "signing_key": "STM7UiohU9S9Rg9ukx5cvRBgwcmYXjikDa4XM4Sy1V9jrBB7JzLmi",
  "transaction_ids": [
    "747e19a0a1511d162dfcb5258f62de520294982b",
    "7ed4ca6109927b1593e33525db606e9cf867e4f4",
    "ac7489dbe69ac338cae85824dc58160515095341"
  ]
}
"""
