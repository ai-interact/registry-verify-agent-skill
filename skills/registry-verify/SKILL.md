---
name: registry-verify
description: Florida business entity lookup in official Florida Division of Corporations records, the data behind Sunbiz. Send a business name and get candidate matches with document number, status, filing type and date, registered agent, officers, home state, and the Florida source file for each record. Use it for KYB before paying, onboarding, or contracting with a Florida company. Florida only. A result is a candidate name match, not proof of identity. 0.10 USDC per lookup over x402 on Base. Also use it when a user asks whether a company is registered or active in Florida, including an out of state company that says it does business in Florida.
license: Proprietary. Florida records are public; answers are provided under the Registry Verify terms.
compatibility: Needs internet access and an x402 version 2 client with a funded USDC wallet on the network named in the 402 response, which is Base mainnet.
metadata:
  publisher: Registry Verify
  homepage: https://registryverify.com
  contact: hello@registryverify.com
  coverage: Florida
  version: "4"
---

# Registry Verify: check a business against Florida records

Registry Verify searches the Florida Division of Corporations public filing
data for a business name and returns the matching filings with the source file
each one came from. Use it as the registry step of a Know Your Business check.

## When to use it

* Before paying an invoice, signing a contract, or onboarding a vendor or
  customer whose business is in Florida.
* When a user asks whether a company is registered, active, or inactive in
  Florida, or who its registered agent or officers are.
* When an out of state company (for example "a Delaware LLC") says it does
  business in Florida. Florida registers those as foreign filings.

## When not to use it

* The business has no Florida connection. Coverage is Florida only, so a
  search tells you nothing about other states.
* You need to verify a person, screen sanctions, or check credit. This is a
  registry lookup only.
* You have no budget for the call. Every lookup is a payment. If the user has
  not authorized spending, ask before you pay.

## Make the call

Send one GET request to the Proceeds charge URL. Put the legal business name
in `name`, URL encoded.

```
GET https://myproceeds.xyz/api/pay/cmupojkok000bjz043ecdfmec/verify-florida-business?name=Publix%20Super%20Markets
```

Optional: `limit` from 1 to 5 sets how many candidate filings come back
(default 5).

Optional: `home_state` takes a two letter United States state code, such as
`DE`, when the user already believes the company was formed in that state.
Filings formed there are listed first, and the answer says plainly when no
Florida registration was found for a company formed there.

```
GET https://myproceeds.xyz/api/pay/cmupojkok000bjz043ecdfmec/verify-florida-business?name=Acme%20Holdings&home_state=DE
```

Payment works like any x402 version 2 resource:

1. The first request returns `402 Payment Required`. The JSON body and the
   `PAYMENT-REQUIRED` header list the accepted payments: network, asset,
   amount, and recipient.
2. Your x402 client signs the payment and repeats the same request with the
   payment attached.
3. Proceeds settles the payment and returns our JSON answer.

Read the network and amount from the 402 response. Do not assume them. The
price is 0.10 USDC (amount `100000`, six decimals).

The paywall runs on Base mainnet (`eip155:8453`), so a lookup is paid with real
USDC. Read the network from the 402 response anyway, and tell the user they are
spending real money before you pay.

Proceeds documents compatible agent wallets at
https://docs.myproceeds.xyz/agents/overview.md

Call only the Proceeds charge URL. No other Registry Verify route accepts
payment, and no API key is issued to buyers.

## Read the answer

```json
{
  "query": "walmart",
  "match_count": 1,
  "matches": [
    {
      "doc_number": "849374",
      "name": "WALMART INC.",
      "status": "<A or I>",
      "status_label": "<Active or Inactive>",
      "filing_type": "<filing type code>",
      "filing_type_label": "<filing type in words>",
      "file_date": "<YYYY-MM-DD>",
      "principal_city": "<city>",
      "principal_zip": "<zip>",
      "ra_name": "<registered agent>",
      "officers": [{"title": "<code>", "type": "<P or C>", "name": "<name>", "city": "<city>", "state": "<state>"}],
      "similarity": "<0 to 1>",
      "provenance": {
        "source": "<Official Florida quarterly corporate archive or daily filing>",
        "publisher": "Florida Division of Corporations",
        "file": "<Florida source file name>",
        "official_source_url": "https://dos.fl.gov/sunbiz/other-services/data-downloads/"
      },
      "history": {
        "first_seen_on": "<YYYY-MM-DD or null>",
        "history_begins_on": "<YYYY-MM-DD or null>",
        "last_status_change": "<object or null>",
        "older_than_history": "<true or false>",
        "note": "<plain sentence about the history window>"
      },
      "home_state": {
        "code": "<two letter code from Florida's record, or null>",
        "name": "<the state in words, or null when we cannot read the code>",
        "is_florida": "<true or false>",
        "code_decoded": "<true or false>",
        "official_search_url": "<that state's official business search, or null>",
        "official_search_authority": "<the office that keeps that register, or null>",
        "sentence": "<plain sentence about where the company was formed>"
      }
    }
  ],
  "same_name_across_home_states": [
    {
      "normalized_name": "<name with case, punctuation, and LLC or INC removed>",
      "florida": [{"doc_number": "<doc>", "name": "<name>"}],
      "out_of_state": [{"doc_number": "<doc>", "name": "<name>", "home_state_code": "<code>", "home_state_name": "<state>"}],
      "sentence": "<plain sentence about one business registering twice>"
    }
  ],
  "home_state_query": {
    "requested": "<the code you sent>",
    "requested_name": "<that state in words, or null>",
    "code_decoded": "<true or false>",
    "match_count_from_there": "<how many of these filings name that home state>",
    "doc_numbers_from_there": ["<doc>"],
    "official_search_url": "<that state's official business search, or null>",
    "sentence": "<plain sentence answering the cross state question>"
  },
  "dataset": {
    "jurisdiction": "Florida",
    "source_file_date_end": "<YYYY-MM-DD>",
    "stale": "<true or false>",
    "authoritative_no_match": false,
    "warning": "<plain sentence about coverage>"
  },
  "result_interpretation": {"match": "...", "no_match": "...", "status": "...", "similarity": "..."}
}
```

Angle brackets mark values that come from the Florida filing. Document
849374 is WALMART INC., a good first test.

* `doc_number` is the Florida document number. Quote it when you report the
  result. Anyone can check it on Sunbiz.
* `status` is what Florida reports: `A` active, `I` inactive.
* `filing_type` starting with `FOR` means an out of state company registered
  in Florida. `file_date` is then the date it registered in Florida, not the
  date it was formed.
* `similarity` compares names only. It runs from 0 to 1. It is not a
  confidence that you found the right company.
* `home_state` is the home state Florida's own record names for the filing. For
  a Florida company it is Florida. For an out of state company it is where the
  company was formed, with the office that keeps that register and a link to
  its official business search. Read `home_state.sentence` and quote it.
* `home_state.code_decoded` is false when Florida's record carries a code that
  is not a United States state code, `OC` among them. Florida publishes the
  field but not the codes it uses, so we return the code and say we do not know
  what it means. Do not guess it, and do not tell the user it is a country.
  Read the filing's `principal_city` and address instead, which are already in
  the answer, and say where Florida's record puts the company rather than what
  the code might stand for.
* `same_name_across_home_states` is present when a Florida filing and an out of
  state filing in these results share a name once case, punctuation, and the
  legal form are removed. That often means one business registered twice, once
  where it was formed and once in Florida. It can also be two unrelated
  businesses, so check a second fact before you merge them.
* `home_state_query` is present only when you sent `home_state`. It says how
  many of these filings name that state and, when none does, that no Florida
  registration was found for a company formed there.
* `provenance.file` names the Florida source file the record came from.
* `history` holds the first time we saw the filing and its most recent status
  change, if we recorded one. Read `history.note`: no recorded change before
  `history_begins_on` does not mean nothing changed.
* `dataset.source_file_date_end` is the newest Florida file we hold. If
  `dataset.stale` is true, tell the user how old the data is.

## Decide what the answer means

* **One strong match.** One candidate, a close name, and a second fact that
  agrees (city, ZIP, registered agent, or an officer the counterparty named).
  Report the document number, status, and source file.
* **Several candidates.** Do not pick one on name alone. Compare city, ZIP,
  officers, and filing date with what you know, or ask the user.
* **Inactive.** Florida reports the filing as inactive. Tell the user before
  any payment or contract. Do not call the business closed; say what Florida
  reports.
* **Out of state.** The filing names another state as its home state. The
  company was formed there and registered to do business in Florida. Report
  both: what Florida says about the Florida registration, and that the company
  itself is held in that state's register, which `home_state.official_search_url`
  links to. Florida's record does not say how the company stands at home.
* **Asked for a home state and none matched.** You sent `home_state` and no
  filing names it. Say that no Florida registration was found for a company
  formed in that state under this name. A company formed elsewhere that does
  business in Florida is normally registered here as a foreign filing, so this
  is a real answer to the user's question, not a failed lookup.
* **No match.** No candidate was found in the covered Florida files. That does
  not prove the business does not exist. Try the exact legal name with its
  suffix (LLC, INC, CORP), check the spelling, and remember the company may be
  registered only in another state.
* **Always** say a registry match is evidence about a filing, not proof of who
  you are dealing with.

## Errors

* `402`: no payment, or the payment failed. Nothing was returned.
* `422`: the name is missing, shorter than 2 or longer than 200 characters, or
  too broad. Add more of the legal name and try again.
* `429`: too many requests. Wait for the `Retry-After` seconds.
* `502` or `504`: our data service failed. Each retry is a new payment, so
  retry at most once.

If you were charged for an error answer, email hello@registryverify.com with
the time of the call and the payment id.

## Limits

* Florida only. At most five candidate filings per call.
* Search is by business name. EIN, address, and officer checks are not
  available yet.
* The home state comes from Florida's record of the company, not from the other
  state's register. We do not check whether the company is in good standing
  where it was formed.
* Data comes from Florida's public daily and quarterly files. To confirm a
  filing made today, ask a person to open Florida's own search in a browser:
  https://search.sunbiz.org/Inquiry/CorporationSearch/ByName (it refuses
  automated clients).

More detail: https://registryverify.com/llms.txt
OpenAPI description of the call: https://registryverify.com/openapi.json
