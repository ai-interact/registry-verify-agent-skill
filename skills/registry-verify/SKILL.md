---
name: registry-verify
description: Florida business entity lookup in official Florida Division of Corporations records, the data behind Sunbiz. Send a business name and get candidate matches with document number, status, filing type and date, registered agent, officers, home state, annual report status, status change history, and the Florida source file for each record. Use it for KYB before paying, onboarding, or contracting with a Florida company. Florida only. A result is a candidate name match, not proof of identity. 0.10 USDC per lookup over x402 on Base. Also use it when a user asks whether a company is registered or active in Florida, whether it has filed its Florida annual report, or about an out of state company that says it does business in Florida.
license: Proprietary. Florida records are public; answers are provided under the Registry Verify terms.
compatibility: Needs internet access and an x402 version 2 client with a funded USDC wallet on the network named in the 402 response, which is Base mainnet.
metadata:
  publisher: Registry Verify
  homepage: https://registryverify.com
  contact: hello@registryverify.com
  coverage: Florida
  version: "6"
---

# Registry Verify: check a business against Florida records

Registry Verify searches the Florida Division of Corporations public filing
data for a business name and returns the matching filings with the source file
each one came from. For each filing it also says which home state Florida's
record names, whether the filing is current on its Florida annual report, and
the last status change we recorded. Use it as the registry step of a Know Your
Business check.

## When to use it

* Before paying an invoice, signing a contract, or onboarding a vendor or
  customer whose business is in Florida.
* When a user asks whether a company is registered, active, or inactive in
  Florida, or who its registered agent or officers are.
* When a user asks whether a Florida company has filed this year's annual
  report, or whether Florida may dissolve it for missing the report.
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

## Free check over MCP (optional)

If your client is connected to the Registry Verify MCP server at
https://registryverify.com/mcp (Streamable HTTP, no sign in), you can first
call its free tool `verify_florida_business` with `business_name`, and
optionally `max_results` (1 to 5) and `home_state`. It checks the name and
gives the date of the newest Florida file we hold. While the hourly free
preview lasts, it also lists the legal names of up to three candidate filings.
It returns the charge URL for that name with `channel=mcp` added, and with
`limit` and `home_state` when you sent `max_results` below 5 or `home_state`.
Pay that URL exactly as returned, without adding parameters; the lookup costs
the same 0.10 USDC. A name the search cannot answer
comes back with no charge URL. The MCP server never takes a payment.

## What one paid answer contains

Every paid answer has these parts:

* `matches`: up to five candidate Florida filings, closest name first. Each
  one carries the filing's own fields (document number, name, status, filing
  type and date, principal city and ZIP, registered agent, officers), the
  Florida source file it came from, its home state, its annual report status,
  and its status history.
* `dataset`: what we searched. The coverage, the dates of the oldest and
  newest Florida daily files we hold, when we last loaded data, and whether
  the data is stale.
* `history_begins_on` and `history_note`: the first date our status change
  history covers, and what that means for older filings.
* `same_name_across_home_states`: each name that a Florida filing and a filing
  formed in another state both hold in these results. It is an empty list when
  there is none.
* `home_state_query`: present only when you sent `home_state`. It says how
  many of these filings name that state as their home state.
* `result_interpretation`: one sentence each on what a match, a no match, a
  status, a similarity score, and a home state mean.

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
      "status_as_reported_by": "Florida Division of Corporations",
      "filing_type": "<filing type code>",
      "filing_type_label": "<filing type in words>",
      "file_date": "<YYYY-MM-DD>",
      "principal_city": "<city>",
      "principal_zip": "<zip>",
      "ra_name": "<registered agent>",
      "officers": [{"title": "<code>", "type": "<P or C>", "name": "<name>", "address": "<street>", "city": "<city>", "state": "<state>", "zip": "<zip>"}],
      "more_than_six_officers": "<true or false>",
      "similarity": "<0 to 1>",
      "similarity_basis": "<what the similarity compares>",
      "source_file": "<Florida source file name>",
      "provenance": {
        "source": "<Official Florida quarterly corporate archive or daily filing>",
        "publisher": "Florida Division of Corporations",
        "file": "<Florida source file name>",
        "official_source_url": "https://dos.fl.gov/sunbiz/other-services/data-downloads/"
      },
      "state_country": "<home state code as Florida's record holds it>",
      "home_state": {
        "code": "<two letter code from Florida's record, or null>",
        "name": "<the state in words, or null when we cannot read the code>",
        "is_florida": "<true or false>",
        "code_decoded": "<true or false>",
        "official_search_url": "<that state's official business search, or null>",
        "official_search_authority": "<the office that keeps that register, or null>",
        "sentence": "<plain sentence about where the company was formed>"
      },
      "annual_reports": [{"year": "<YYYY>", "filed_on": "<YYYY-MM-DD>"}],
      "annual_report": {
        "state": "<filed, due, late, dissolution_date_passed, not_due_yet, inactive, unknown, or rule_not_checked>",
        "current_year": "<YYYY>",
        "current_year_filed": "<true, false, or null>",
        "latest_year": "<YYYY or null>",
        "latest_filed_on": "<YYYY-MM-DD or null>",
        "due_by": "<1 May of this year>",
        "dissolution_date": "<fourth Friday of September this year>",
        "sentence": "<plain sentence about the annual report>",
        "source_file": "<Florida file the reports were read from>",
        "source_file_date": "<YYYY-MM-DD or null>",
        "data_refreshed_at": "<when our last import finished>",
        "rule_sources": ["<Florida Statutes sections>", "https://dos.fl.gov/sunbiz/manage-business/efile/annual-report/"]
      },
      "history": {
        "first_seen_on": "<YYYY-MM-DD or null>",
        "history_begins_on": "<YYYY-MM-DD or null>",
        "last_status_change": {"date": "<YYYY-MM-DD>", "status": "<A or I>", "status_label": "<Active or Inactive>", "source_file": "<Florida daily file>"},
        "older_than_history": "<true or false>",
        "note": "<plain sentence about the history window>"
      }
    }
  ],
  "dataset": {
    "jurisdiction": "Florida",
    "coverage": "<quarterly_corporate_snapshot_with_daily_updates or partial_daily_files>",
    "complete_registry": false,
    "quarterly_snapshot_loaded": "<true or false>",
    "authoritative_no_match": false,
    "record_count": "<records we hold>",
    "source_file_count": "<Florida files loaded>",
    "quarterly_source_file_count": "<files from the quarterly snapshot>",
    "represented_daily_source_file_count": "<daily files>",
    "source_file_date_start": "<YYYY-MM-DD>",
    "source_file_date_end": "<YYYY-MM-DD>",
    "latest_event_source_file": "<newest Florida status event file>",
    "latest_event_file_date": "<YYYY-MM-DD>",
    "source_retrieved_at": "<when we last downloaded from Florida>",
    "last_ingested_at": "<when our last import finished>",
    "expected_source_records": "<records our last import expected>",
    "imported_records": "<records it imported>",
    "quarantined_records": "<records it set aside: no document number or name, or a future filing date>",
    "import_status": "<result of the last import>",
    "stale": "<true or false>",
    "warning": "<plain sentence about coverage>"
  },
  "history_begins_on": "<YYYY-MM-DD or null>",
  "history_note": "<plain sentence about how far back our history goes>",
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
    "official_search_authority": "<the office that keeps that register, or null>",
    "sentence": "<plain sentence answering the cross state question>"
  },
  "result_interpretation": {"match": "...", "no_match": "...", "status": "...", "similarity": "...", "home_state": "..."}
}
```

Angle brackets mark values that come from the Florida filing or from our
data. Document 849374 is WALMART INC., a good first test.

### The filing

* `doc_number` is the Florida document number. Quote it when you report the
  result. Anyone can check it on Sunbiz.
* `status` is what Florida reports: `A` active, `I` inactive.
  `status_as_reported_by` names who reports it, the Florida Division of
  Corporations.
* `filing_type` starting with `FOR` means an out of state company registered
  in Florida. `file_date` is then the date it registered in Florida, not the
  date it was formed.
* `officers` lists up to six officers or managers with their titles and
  addresses as Florida's record holds them. `more_than_six_officers` is true
  when Florida's record says the filing has more.
* `similarity` compares names only. It runs from 0 to 1. It is not a
  confidence that you found the right company. `similarity_basis` says what
  was compared.
* `source_file` and `provenance.file` name the Florida source file the record
  came from. `provenance` also names the publisher and links the Division's
  data download page.

### Home state

* `home_state` is the home state Florida's own record names for the filing. For
  a Florida company it is Florida. For an out of state company it is where the
  company was formed, with the office that keeps that register and a link to
  its official business search. Read `home_state.sentence` and quote it.
  `state_country` is the raw code as Florida's record holds it.
* `home_state.code_decoded` is false when Florida's record carries a code that
  is not a United States state code, `OC` among them. Florida publishes the
  field but not the codes it uses, so we return the code and say we do not know
  what it means. Do not guess it, and do not tell the user it is a country.
  Read the filing's `principal_city` and `principal_zip` instead, which are
  already in the answer, and say where Florida's record puts the company rather
  than what the code might stand for.
* `same_name_across_home_states` lists each name that a Florida filing and an
  out of state filing in these results share once case, punctuation, and the
  legal form are removed. That often means one business registered twice, once
  where it was formed and once in Florida. It can also be two unrelated
  businesses, so check a second fact before you merge them.
* `home_state_query` is present only when you sent `home_state`. It says how
  many of these filings name that state and, when none does, that no Florida
  registration was found for a company formed there.

### Annual report

Florida requires an annual report between 1 January and 1 May of every year
after the year a filing was made. A filing still missing it on the third Friday
of September is dissolved on the fourth Friday of September, or, for a company
formed in another state, has its Florida registration revoked.

* `annual_report.sentence` says what Florida's files show about this year's
  report. Read it and quote it.
* `annual_report.state` is one of:
  * `filed`: this year's report is on file. The sentence says when, and
    whether it came after the 1 May deadline.
  * `due`: this year's report is not on file yet and 1 May has not passed.
  * `late`: 1 May has passed and this year's report is not on file. Florida
    dissolves or revokes on `annual_report.dissolution_date` if it is still
    missing.
  * `dissolution_date_passed`: that September date has gone by without the
    report. The status in our answer may not show the dissolution until we
    load Florida's next quarterly file, and the sentence says so.
  * `not_due_yet`: the filing was made this year, so its first report is due
    next year.
  * `inactive`: Florida lists the filing as inactive, so it owes no report.
  * `unknown` or `rule_not_checked`: we cannot say. The sentence says why.
* `due_by` and `dissolution_date` are this year's two dates. `latest_year` and
  `latest_filed_on` are the newest report on file. `current_year_filed` is
  true or false, or null when we cannot tell or no report is owed yet.
* `source_file` and `source_file_date` name the Florida file the reports were
  read from. `data_refreshed_at` is when our last import finished.
  `rule_sources` links the Florida Statutes sections and the Sunbiz page the
  rule comes from.
* `annual_reports` is the raw list Florida's record holds: up to its last three
  reports, each with a year and a filing date. Florida often repeats the same
  report twice in that list.

### Status history

* `history` holds the first date we saw the filing in Florida's daily files
  (`first_seen_on`) and its most recent status change, if we recorded one
  (`last_status_change`, with the date, the new status, and the daily file it
  came from). Both are null when we recorded nothing.
* `history_begins_on` is the first date our history covers, and
  `older_than_history` is true when the filing is older than that. Read
  `history.note`: no recorded change does not mean nothing changed before
  `history_begins_on`. The top level `history_begins_on` and `history_note`
  say the same for the whole answer.

### The data behind the answer

* `dataset.source_file_date_end` is the date of the newest Florida daily file we
  hold, and `dataset.source_file_date_start` the oldest.
  `dataset.latest_event_source_file` and `dataset.latest_event_file_date` name
  the newest Florida status event file we loaded.
* `dataset.last_ingested_at` is when our last import finished and
  `dataset.source_retrieved_at` when we last downloaded from Florida.
  `dataset.stale` is true when that last import finished more than seven days
  ago. If it is true, tell the user how old the data is.
* `dataset.coverage`, `dataset.quarterly_snapshot_loaded`, `dataset.record_count`
  and the file counts say what we searched. `dataset.expected_source_records`,
  `dataset.imported_records`, `dataset.quarantined_records` and
  `dataset.import_status` describe our last import.
* `dataset.complete_registry` and `dataset.authoritative_no_match` are false on
  every answer, because we do not claim that the files we hold contain every
  Florida filing. `dataset.warning` says so in one sentence.

## Decide what the answer means

* **One strong match.** One candidate, a close name, and a second fact that
  agrees (city, ZIP, registered agent, or an officer the counterparty named).
  Report the document number, status, and source file.
* **Several candidates.** Do not pick one on name alone. Compare city, ZIP,
  officers, and filing date with what you know, or ask the user.
* **Inactive.** Florida reports the filing as inactive. Tell the user before
  any payment or contract. Do not call the business closed; say what Florida
  reports.
* **Annual report late or past the dissolution date.** `annual_report.state` is
  `late` or `dissolution_date_passed`. Quote `annual_report.sentence` to the
  user before any payment or contract. Do not say the company is dissolved
  unless Florida's status says so; say what Florida's files show.
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
* The annual report status comes from Florida's files as we last loaded them,
  so a report filed after that file may not show yet.
* Our status change history starts on `history_begins_on`. We hold no changes
  from before that date.
* Data comes from Florida's public daily and quarterly files. To confirm a
  filing made today, ask a person to open Florida's own search in a browser:
  https://search.sunbiz.org/Inquiry/CorporationSearch/ByName (it refuses
  automated clients).

More detail: https://registryverify.com/llms.txt
OpenAPI description of the call: https://registryverify.com/openapi.json
This skill on GitHub: https://github.com/ai-interact/registry-verify-agent-skill
