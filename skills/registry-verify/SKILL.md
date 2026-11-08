---
name: registry-verify
description: Florida business entity lookup in official Florida Division of Corporations records, the data behind Sunbiz. Send a business name and get candidate matches with document number, status, filing type and date, registered agent, officers, home state, annual report status, status change history, and the Florida source file for each record. Use it for KYB before paying, onboarding, or contracting with a Florida company. Florida only. A result is a candidate name match, not proof of identity. 0.10 USDC per lookup over x402 on Base. Also use it when a user asks whether a company is registered or active in Florida, whether it has filed its Florida annual report, about an out of state company that says it does business in Florida, or holds an old name for a company.
license: Proprietary. Florida records are public; answers are provided under the Registry Verify terms.
compatibility: Needs internet access and an x402 version 2 client with a funded USDC wallet on the network named in the 402 response, which is Base mainnet.
metadata:
  publisher: Registry Verify
  homepage: https://registryverify.com
  contact: hello@registryverify.com
  coverage: Florida
  version: "10"
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
* When a user holds an old name for a company, such as one on an old invoice.
* When a user asks whether other companies list the same address, registered
  agent or officer as this one.

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
the same 0.10 USDC. A name made only of words like Inc or LLC, or with no three
letters or digits in a row, comes back with no charge URL. The preview searches
current names only. The MCP server never takes a payment.

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
* Warning flags: `flag_rules`, and on each match `flags`, `review_suggested`
  and `flags_not_checked`. See Warning flags.
* `shared_records` on each match: how many Florida filings list the same
  address, registered agent or officer. See Shared records.
* Former names: `found_by`, `matched_name`, `renamed_on` and `name_history` on
  each match, and `former_names_searched` and `former_name_coverage` for the
  answer. See Former names.

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
data. Document 849374 is WALMART INC., a good first test. Every paid answer
also carries the warning flag fields, which the sample under Warning flags
shows, and the fields the samples under Shared records and Former names show.

### The filing

* `doc_number` is the Florida document number. Quote it when you report the result. Anyone can check it on Sunbiz.
* `status` is what Florida reports: `A` active, `I` inactive. `status_as_reported_by` names who reports it, the Florida Division of Corporations.
* `filing_type` starting with `FOR` means an out of state company registered in Florida. `file_date` is then the date it registered in Florida, not the date it was formed.
* `officers` lists up to six officers or managers with their titles and addresses as Florida's record holds them. `more_than_six_officers` is true when Florida's record says the filing has more.
* `similarity` compares names only. It runs from 0 to 1. It is not a confidence that you found the right company. `similarity_basis` says what was compared. Name search says what each score means.
* `source_file` and `provenance.file` name the Florida source file the record came from. `provenance` also names the publisher and links the Division's data download page.

### Home state

* `home_state` is the home state Florida's own record names for the filing. For a Florida company it is Florida. For an out of state company it is where the company was formed, with the office that keeps that register and a link to its official business search. Read `home_state.sentence` and quote it. `state_country` is the raw code as Florida's record holds it.
* `home_state.code_decoded` is false when Florida's record carries a code that is not a United States state code, `OC` among them. Florida publishes the field but not the codes it uses, so we return the code and say we do not know what it means. Do not guess it, and do not tell the user it is a country. Read the filing's `principal_city` and `principal_zip` instead, which are already in the answer, and say where Florida's record puts the company rather than what the code might stand for.
* `same_name_across_home_states` lists each name that a Florida filing and an out of state filing in these results share once case, punctuation, and the legal form are removed. That often means one business registered twice, once where it was formed and once in Florida. It can also be two unrelated businesses, so check a second fact before you merge them.
* `home_state_query` is present only when you sent `home_state`. It says how many of these filings name that state and, when none does, that no Florida registration was found for a company formed there.

### Annual report

Florida requires an annual report between 1 January and 1 May of every year
after the year a filing was made. A filing still missing it on the third Friday
of September is dissolved on the fourth Friday of September, or, for a company
formed in another state, has its Florida registration revoked.

* `annual_report.sentence` says what Florida's files show about this year's report. Read it and quote it.
* `annual_report.state` is one of:
  * `filed`: this year's report is on file. The sentence says when, and whether it came after the 1 May deadline.
  * `due`: this year's report is not on file yet and 1 May has not passed.
  * `late`: 1 May has passed and this year's report is not on file. Florida dissolves or revokes on `annual_report.dissolution_date` if it is still missing.
  * `dissolution_date_passed`: that September date has gone by without the report. The status in our answer may not show the dissolution until we load Florida's next quarterly file, and the sentence says so.
  * `not_due_yet`: the filing was made this year, so its first report is due next year.
  * `inactive`: Florida lists the filing as inactive, so it owes no report.
  * `unknown` or `rule_not_checked`: we cannot say. The sentence says why.
  * With the warning flags, a filing past the dissolution date without this year's report can instead be `listed_active_after_dissolution_date` or, if made 1 October to 31 December last year, `first_report_may_be_next_year` (a later Florida file still lists it as active), or `reinstated_after_dissolution_date` (a later Florida daily file set it back to active). `status_source_file`, `set_active_source_file` and their dates name those files.
* `due_by` and `dissolution_date` are this year's two dates. `latest_year` and `latest_filed_on` are the newest report on file. `current_year_filed` is true or false, or null when we cannot tell or no report is owed yet.
* `source_file` and `source_file_date` name the Florida file the reports were read from. `data_refreshed_at` is when our last import finished. `rule_sources` links the Florida Statutes sections and the Sunbiz page the rule comes from.
* `annual_reports` is the list Florida's record holds: up to its last three reports, each with a year and a filing date. A report the record repeats is listed once, so the list can be shorter than three. Two entries for one year are a report and its amendment.

### Status history

* `history` holds the first date we saw the filing in Florida's daily files (`first_seen_on`) and its most recent status change, if we recorded one (`last_status_change`, with the date, the new status, and the daily file it came from). Both are null when we recorded nothing.
* `history_begins_on` is the first date our history covers, and `older_than_history` is true when the filing is older than that. Read `history.note`: no recorded change does not mean nothing changed before `history_begins_on`. The top level `history_begins_on` and `history_note` say the same for the whole answer.

### The data behind the answer

* `dataset.source_file_date_end` is the date of the newest Florida daily file we hold, and `dataset.source_file_date_start` the oldest. `dataset.latest_event_source_file` and `dataset.latest_event_file_date` name the newest Florida status event file we loaded.
* `dataset.status_lag` says how a status can lag. Between Florida's quarterly files a status comes from Florida's daily event files, and those files miss some events, so a filing can show as active after it closed, or as inactive after it was reinstated, until the next quarterly file. The same gap can leave a warning flag out. When a decision depends on status, tell the user and suggest checking the filing on Florida's Sunbiz site.
* `dataset.event_files_repeated` lists the days since the last quarterly file on which Florida posted the previous day's event file again, oldest first. Events filed around those days are the most likely to be missing. It is null when we could not read them.
* `dataset.last_ingested_at` is when our last import finished and `dataset.source_retrieved_at` when we last downloaded from Florida. `dataset.stale` is true when that last import finished more than seven days ago. If it is true, tell the user how old the data is.
* `dataset.coverage`, `dataset.quarterly_snapshot_loaded`, `dataset.record_count` and the file counts say what we searched. `dataset.expected_source_records`, `dataset.imported_records`, `dataset.quarantined_records` and `dataset.import_status` describe our last import.
* `dataset.complete_registry` and `dataset.authoritative_no_match` are false on every answer, because we do not claim that the files we hold contain every Florida filing. `dataset.warning` says so in one sentence.

## Warning flags

Every paid answer carries warning flags: a `flag_rules` block, and on each
match `flags`, `review_suggested` and `flags_not_checked`. An answer without
`flag_rules` was not checked against these rules, so the missing fields say
nothing about the company.

A warning flag is a short reason to look closer before you trust a company.
Each flag states one fact from Florida's record and carries the record or
event that caused it. A flag is never a fraud verdict, and there is no score.

```json
{
  "matches": [
    {
      "flags": [
        {
          "code": "<rule name, such as agent_changed_recently>",
          "rule": "<rule name@version, such as agent_changed_recently@1>",
          "severity": "<high, review, or info>",
          "sentence": "<one plain sentence about Florida's record>",
          "date": "<YYYY-MM-DD of the record or event behind the flag, or null>",
          "source_file": "<Florida file that record or event came from, or null>",
          "evidence": {
            "fields": {"filing_type": "<each match field the rule read>"},
            "events": [{"code": "<Florida event code>", "description": "<Florida's own words>", "filed_on": "<YYYY-MM-DD>", "effective_on": "<YYYY-MM-DD or null>", "source_file": "<Florida event file>"}],
            "window_days": "<the rule's threshold>",
            "official_source_url": "https://dos.fl.gov/sunbiz/other-services/data-downloads/"
          }
        }
      ],
      "review_suggested": "<true or false>",
      "flags_not_checked": [{"code": "<rule name>", "reason": "<why it could not run>"}],
      "annual_report": {"status_source_file": "<file our status came from, or null>", "status_source_file_date": "<YYYY-MM-DD or null>", "set_active_source_file": "<daily file that set it back to active, or null>", "set_active_source_file_date": "<YYYY-MM-DD or null>"}
    }
  ],
  "flag_rules": {
    "version": "1", "as_of": "<YYYY-MM-DD, the day in Florida the rules ran>", "event_history_through": "<YYYY-MM-DD of the newest Florida event file we loaded, or null>",
    "rules": ["inactive@1", "<every rule that ran>"], "severity_display": {"high": "red", "review": "amber", "info": "grey"}, "documentation_url": "https://registryverify.com/llms.txt"
  },
  "result_interpretation": {"flags": "<what an empty flags list means>"}
}
```

The evidence shown is `agent_changed_recently`'s; each rule gives the fields
and events it read.

* `rule` is the `code` and its version. A changed threshold or meaning gets a
  new version, so you can tell a changed rule from a changed company.
  `severity` is `high`, `review` or `info`, shown red, amber and grey
  (`flag_rules.severity_display`), highest first.
* Quote `sentence`; Florida's own words for an event stay in
  `evidence.events[].description`. `date` is null when no single date applies.
* `evidence` also holds the rule's thresholds (`window_days`,
  `threshold_days`, `min_age_days`, `near_days`), `events[].name` (a rename's
  new name) and `official_source_url`, Florida's data download page.
* `review_suggested` is true when a `high` or `review` flag fired on the
  match. `flags_not_checked` names each rule that could not run, with a
  `reason`. An empty `flags` list does not mean the company is safe.
* `flag_rules.as_of` is the day every window counts back from. An event filed
  after `event_history_through` cannot raise a flag yet.

| Rule | Severity | Fires when |
|---|---|---|
| `inactive@1` | high | Florida lists the filing as inactive. The sentence names its last ending event, such as a dissolution, when Florida's event history has one. |
| `annual_report_missed@1` | high or review | This year's annual report is not on file and the fourth Friday of September has passed. High when our status comes from a Florida file dated before that day, so Florida has probably dissolved the filing, or revoked its Florida registration, since. Review when a later Florida file still lists it as active, or a later Florida daily file set it back to active. |
| `control_changed_after_reinstatement@1` | high | An active filing at least 730 days old that Florida reinstated in the last 365 days, with a change of registered agent, an amendment to its articles or a name change filed within 180 days of the reinstatement. Someone taking over a dormant company leaves this pattern: confirm the people behind it with the company. |
| `no_registered_agent@1` | high | Florida's record for this active filing names no registered agent. |
| `annual_report_late@1` | review | From 2 May to the fourth Friday of September, this year's annual report is not on file. |
| `reinstated_recently@1` | review | Florida reinstated this active filing, or undid its dissolution, in the last 365 days. |
| `formed_recently@1` | review | This active filing was formed in Florida, or registered there when formed elsewhere, fewer than 90 days before the lookup. |
| `agent_changed_recently@1` | review | Florida recorded a statement changing the registered agent or registered office in the last 90 days. Florida records it only for limited liability companies. |
| `name_changed_recently@1` | review | Florida recorded a change of the filing's name in the last 365 days. |
| `no_officers_listed@1` | review | This active for-profit corporation or limited liability company (filing type DOMP, FORP, FLAL or FORL) lists no officers, managers or members. |
| `officer_list_partial@1` | info | Florida says the filing has more than six officers but its data file carries six, so the list is partial. Sunbiz shows the full list. |
| `name_differs_from_query@1` | info | The filing's name is not the name you sent, even ignoring case, punctuation and the legal ending, so check it is the company you mean. |

`agent_changed_recently` and `name_changed_recently` also run on inactive
filings. The event rules read the newest 20 events Florida filed for the
filing from 1 January 2016 to the lookup date. For a code not listed here, act
on its `severity` and quote its `sentence`. Shared records lists four more
flags. `flag_rules.rules` does not list them: each names its rule in `rule`.

## Name search

Will the search find the company when the name is not written exactly as Florida holds it? It sets aside case, punctuation, The at the start and the legal ending, writes common abbreviations out, and finds a filing when the legal ending differs, when two to four words come in another order, or when a word is misspelled. A common name such as Florida gets an answer.

`similarity_basis` is `name_match_score`, and `similarity` means:

* 1.00: the same name apart from the legal ending. Inc for an LLC still scores 1.00.
* 0.99: the same name, when the filing has more legal ending words than you sent, such as KROGER COMPANY, INC. for Kroger.
* 0.98: the same letters spaced differently, such as WAL MART for Walmart.
* Below 0.98: the names are less alike. The score weighs how much of the name you sent the filing's name holds. An open filing gets 0.03 more, up to 0.979.

When this search cannot answer, an older search does: `similarity_basis` says `entity_name_similarity`, `similarity` compares the letters of the two names, and these meanings do not apply. A name needs at least 2 letters or digits, or it gets `422` and no search runs.

A brand word alone, such as Publix, can still list other filings that share the word first, so send the full legal name when you have it.

## Shared records

Do other Florida companies list the same address, registered agent or officer as this one? Every paid answer carries `shared_records` on each match. A match without `shared_records` was not checked against these counts, so the missing block says nothing about the company.

We return counts only. We never list which other filings share these records. A shared record is a reason to look closer, not proof of a problem. A flag is never a fraud verdict, and there is no score.

```json
{
  "matches": [
    {
      "shared_records": {
        "state": "<counted, not_counted, or unavailable>",
        "counted_over": "all Florida filings in our copy, active and inactive",
        "as_of": "<YYYY-MM-DD of the Florida file the counts reach, or null>",
        "as_of_source_file": "<that Florida file, or null>",
        "principal_address": {"normalized": "<the address as we count it>", "filings": "<filings at this address, this one included>", "active": "<how many of them are open>", "other_filings": "<the same, leaving this filing out>", "other_active": "<the same, leaving this filing out>", "kind": "<street_address, registered_agent_address, po_box, or mail_drop_pattern>", "agent_name": "<the registered agent at this address, or null>", "building": {"normalized": "<the address without its unit>", "filings": "<filings in the building>", "active": "<how many of them are open>", "units": "<different unit numbers>"}, "sentence": "<plain sentence about this address>"},
        "registered_agent": {"normalized": "<agent name>", "zip": "<ZIP of a person agent, or null>", "agent_type": "<company or person>", "filings": "<filings naming this agent>", "active": "<how many of them are open>", "other_filings": "<the same, leaving this filing out>", "other_active": "<the same, leaving this filing out>", "kind": "<commercial_registered_agent, professional_registered_agent, company, or person>", "sentence": "<plain sentence about this agent>"},
        "officers": [{"name": "<officer name>", "zip": "<ZIP>", "officer_type": "<company or person>", "filings": "<filings listing this officer>", "active": "<how many of them are open>", "other_filings": "<the same, leaving this filing out>", "other_active": "<the same, leaving this filing out>", "sentence": "<plain sentence about this officer>"}],
        "flags": [{"code": "<flag name>", "rule": "<flag name@version>", "severity": "review", "sentence": "<one plain sentence>", "date": "<as_of>", "source_file": "<as_of_source_file>", "evidence": {"field": "<principal_address, registered_agent, or officers>", "normalized": "<the record>", "name": "<officer name>", "zip": "<ZIP>", "filings": "<count>", "active": "<count>", "other_active": "<count>", "threshold": "<the rule's minimum>", "busiest_officer_other_active": "<count>", "building_units": "<count>", "building": "<the address without its unit>", "building_filings": "<count>", "units": "<count>", "threshold_filings": "<the rule's minimum>", "threshold_units_per_filing": "<the rule's minimum>", "counts_as_of": "<as_of>", "counts_source_file": "<as_of_source_file>", "official_source_url": "https://dos.fl.gov/sunbiz/other-services/data-downloads/"}}],
        "note": "<counts only, and a reason to look closer>",
        "sentence": "<only when state is not_counted or unavailable>",
        "flags_not_checked": [{"code": "<flag name>", "reason": "<only when state is unavailable>"}]
      }
    }
  ]
}
```

* `state` is `counted`; `not_counted`, when we hold no principal address with a ZIP code, registered agent or officer with a ZIP code to count, so no flag below can fire; or `unavailable`, when the counts could not be read for this answer. The block then holds only `state`, `sentence`, `flags` and `flags_not_checked`, and the four flags are also listed under the match's `flags_not_checked`.
* `active` counts the open filings: the ones Florida lists as active. `other_filings` and `other_active` leave this filing out. Quote each `sentence`.
* `kind` says what a count means. `registered_agent_address`, `commercial_registered_agent` and `professional_registered_agent` say nothing about the company, because many companies share them. `mail_drop_pattern` is a building with at least 300 filings and at least one unit number per two filings. A commercial or professional agent is agent for at least 1,000 filings.

| Rule | Severity | Fires when |
|---|---|---|
| `principal_address_shared_by_many@1` | review | 100 or more other open filings list this exact principal address, it is not a registered agent's address or a post office box, no officer of this filing is an officer of at least half as many open filings, and the address has a unit or its building has fewer than 10 units. |
| `principal_address_is_mailbox_pattern@2` | review | The building holds 300 or more filings under at least one unit number per two filings. |
| `person_agent_for_many@1` | review | A person who is registered agent for fewer than 1,000 filings is agent for 100 or more other open filings. |
| `officer_on_many@1` | review | One officer, by name and ZIP code, is an officer of 50 or more other open filings. |

## Former names

Has this company gone by another name, and can an old name find it? The search covers the former names we hold as well as current names, so a name from an old invoice can find a filing renamed since.

```json
{
  "matches": [
    {
      "found_by": "<current_name or former_name>",
      "matched_name": "<only for former_name: the former name that matched>",
      "renamed_on": "<only for former_name: YYYY-MM-DD it stopped being used, or null>",
      "name_history": {
        "former_names": [{"name": "<former name>", "used_until": "<YYYY-MM-DD or null>", "renamed_by": "<Florida's own words for the change, or null>", "source_file": "<Florida file>"}],
        "renames_recorded": "<how many renames we hold>",
        "last_renamed_on": "<YYYY-MM-DD or null>",
        "earlier_name_unknown": "<true when Florida's bulk files lack the name before a rename>",
        "note": "<plain sentences about the names>"
      }
    }
  ],
  "former_names_searched": "<true or false>",
  "former_name_coverage": "<plain sentence on what the former names cover>"
}
```

* `former_names_searched` is false when only current names were matched for this answer. `found_by` is present when it is true. Quote `former_name_coverage` and `name_history.note`.
* `former_names` lists newest first, at most 10. A former name match's `similarity` is scored on that name, times 0.97.
* A match without `name_history` was not checked for renames, because that read failed, so the missing block says nothing about whether the company was renamed.
* The list order: current names that score 0.98 or more, then filings whose former name has the same letters and digits as the name you sent, then other current names, then other former name matches. The original name of a filing formed before 2008 and renamed once is not in Florida's bulk files, so such a filing can be found only by its current name.

## Decide what the answer means

* **One strong match.** One candidate, a close name, and a second fact that agrees (city, ZIP, registered agent, or an officer the counterparty named). Report the document number, status, and source file.
* **Several candidates.** Do not pick one on name alone. Compare city, ZIP, officers, and filing date with what you know, or ask the user.
* **Inactive.** Florida reports the filing as inactive. Tell the user before any payment or contract. Do not call the business closed; say what Florida reports.
* **Annual report late or past the dissolution date.** `annual_report.state` is `late` or `dissolution_date_passed`. Quote `annual_report.sentence` to the user before any payment or contract. Do not say the company is dissolved unless Florida's status says so; say what Florida's files show.
* **Warning flags.** When `review_suggested` is true, quote each `high` and `review` flag's `sentence` to the user before any payment or contract, and suggest confirming those facts with the company. Do not call a flag fraud. When `flags` is empty, say no warning flag fired, not that the company is safe, and name any rule in `flags_not_checked`.
* **A shared record.** Read `kind` first, then quote the `sentence`. Report the count as a reason to look closer, not proof of a problem. The answer cannot tell you which other filings share the record.
* **Found by a former name.** `found_by` is `former_name`. Say that the filing has another legal name now, quote `name_history.note`, and check a second fact before you treat it as the company you mean.
* **Out of state.** The filing names another state as its home state. The company was formed there and registered to do business in Florida. Report both: what Florida says about the Florida registration, and that the company itself is held in that state's register, which `home_state.official_search_url` links to. Florida's record does not say how the company stands at home.
* **Asked for a home state and none matched.** You sent `home_state` and no filing names it. Say that no Florida registration was found for a company formed in that state under this name. A company formed elsewhere that does business in Florida is normally registered here as a foreign filing, so this is a real answer to the user's question, not a failed lookup.
* **No match.** No candidate was found in the covered Florida files. That does not prove the business does not exist. Try the exact legal name with its suffix (LLC, INC, CORP), check the spelling, and remember the company may be registered only in another state. Read `former_name_coverage` for what the former names we hold cover.
* **Always** say a registry match is evidence about a filing, not proof of who you are dealing with.

## Errors

* `402`: no payment, or the payment failed. Nothing was returned.
* `422`: the name is missing, shorter than 2 or longer than 200 characters, has fewer than 2 letters or digits, or is too broad. Add more of the legal name and try again. Proceeds settles the payment before it forwards the call, so check the name before you pay.
* `429`: too many requests. Wait for the `Retry-After` seconds.
* `502` or `504`: our data service failed. Each retry is a new payment, so retry at most once.

If you were charged for an error answer, email hello@registryverify.com with
the time of the call and the payment id.

## Limits

* Florida only. At most five candidate filings per call.
* Search is by business name. EIN, address, and officer checks are not available yet. Shared record counts never say which filings share a record.
* The home state comes from Florida's record of the company, not from the other state's register. We do not check whether the company is in good standing where it was formed.
* The annual report status comes from Florida's files as we last loaded them, so a report filed after that file may not show yet.
* Our status change history starts on `history_begins_on`. We hold no changes from before that date.
* Data comes from Florida's public daily and quarterly files. To confirm a filing made today, ask a person to open Florida's own search in a browser: https://search.sunbiz.org/Inquiry/CorporationSearch/ByName (it refuses automated clients).

More detail: https://registryverify.com/llms.txt
OpenAPI description of the call: https://registryverify.com/openapi.json
This skill on GitHub: https://github.com/ai-interact/registry-verify-agent-skill
