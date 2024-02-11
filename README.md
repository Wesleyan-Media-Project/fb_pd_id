# Wesleyan Media Project - fb_pd_id

Welcome! This repo is part of the Cross-platform Election Advertising Transparency initiatIVE ([CREATIVE](https://www.creativewmp.com/)) project. CREATIVE is a joint infrastructure project of WMP and privacy-tech-lab at Wesleyan University. CREATIVE provides cross-platform integration and standardization of political ads collected from Google and Facebook.

This repo is a part of the Data Collection step.

## Table of Contents

- [Introduction](#introduction)
  - [Background](#background)
- [Objective](#objective)
- [Data](#data)
- [Scripts](#Scripts)

## Introduction

This repo contains scripts for generating the FB entity ids - pd_ids - used by WMP. "pd_id" stands for
page name-disclaimer identifier". This identifier is pivotal for linking Facebook advertisements to political entities without the reliance on FEC identifiers.

### Background

Wesleyan Media Project tracks the amount of money spent by political actors on advertising during electoral campaigns. Because Facebook does not require from advertisers to provide FEC identifiers, WMP has to link the Facebook ads to political candidates on its own. Technically, an ad is run from a single page. A page is uniquely identified by its id. However, some pages engage in an activity where they run ads for various organizations and candidates. This is revealed in the PFB - "paid for by" string, also known as "disclaimer" or "funding entity", in an ad's record. Such activity is especially wide-spread among pages backed by interest groups - they would run ads promoting one candidate, then run ads in support of another candidate. The page id stays the same, but the disclaimer string is different.

Thus, the full information about the funders of an ad is contained in the combination of a page id and the disclaimer string. For this reason, WMP generates what internally is known as "pd_ids" - a string combining the Facebook's page id and a numeric code for the PFB string used by that page. This repository provides the scripts used to generate and store the fb_pd_id strings.

## Objective

Each of our repos belongs to one or more of the following categories:

- Data Collection
- Data Storage & Processing
- Preliminary Data Classification
- Final Data Classification

This repo is part of the Data Collection section.

## Data

The primary output of this repo `pd_id_snapshot.csv` is in `csv` format. It contains unique combinations of page_id, diclaimer, pd_id, and op_num. If there are new pd_ids that need to be inserted (indicated by the presence of rows in x5), this repo would first insert the new pd_ids into the fb_pd_id table, and then call the `load_fb_pd_id.sh` script to upload the pd_id_snapshot.csv file to a Google Cloud Storage bucket and finally load it into a BigQuery table.

## Scripts

The main script is `update_fb_pd_id.R`. It interacts with the table of ads `race2022` and the table of pd_ids - `fb_pd_id`.

It retrieves all combinations of page ids and disclaimers from the table of ads. Then it removes the combinations that are already present in the `fb_pd_id` table. After that, it generates numeric codes for the new disclaimer strings for each of the page ids. The final steps involve inserting the new rows into the `fb_pd_id` table in MySQL database and also storing a copy of the `fb_pd_id` in Google BigQuery.

The copying of `fb_pd_id` to BigQuery is done by the `load_fb_pd_id.sh` script that uses Unix command line interpreter bash. THe script is launched as a subprocess inside the `update_fb_pd_id.R` script.
