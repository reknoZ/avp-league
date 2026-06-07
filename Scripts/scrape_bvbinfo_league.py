#!/usr/bin/env python3
"""Scrape AVP League match results from bvbinfo.info for 2024 and 2025."""

from __future__ import annotations

import json
import re
import urllib.request
from dataclasses import dataclass
from datetime import datetime
from html import unescape
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = ROOT / "AVP League/Resources/HistoricalMatches"

TEAM_NAME_TO_ID = {
    "Austin Aces": "aa",
    "Brooklyn Blaze": "bb",
    "Dallas Dream": "dd",
    "Los Angeles Launch": "lal",
    "Miami Mayhem": "mm",
    "New York Nitro": "nyn",
    "Palm Beach Passion": "pbp",
    "San Diego Smash": "sds",
}

VENUE_BY_WEEK = {
    2024: {
        1: "Los Angeles, CA",
        2: "Miami, FL",
        3: "San Diego, CA",
        4: "Austin, TX",
        5: "Palm Beach, FL",
        6: "Oceanside, CA",
        7: "Anaheim, CA",
        8: "Dallas, TX",
        9: "Los Angeles, CA",
    },
    2025: {
        1: "Palm Beach, FL",
        2: "San Diego, CA",
        3: "Atlanta, GA",
        4: "East Hampton, NY",
        5: "Los Angeles, CA",
        6: "New York, NY",
        7: "Austin, TX",
        8: "Dallas, TX",
        9: "Chicago, IL",
    },
}

HOURS = [11, 12, 15, 16]


@dataclass
class ScrapedRow:
    season_year: int
    team_id: str
    division: str
    month: int
    day: int
    week: int
    venue: str
    opponent_id: str
    team_sets_won: int
    opponent_sets_won: int
    sets: list[tuple[int, int]]


def fetch(url: str, retries: int = 3) -> str:
    last_error: Exception | None = None
    for attempt in range(retries):
        try:
            request = urllib.request.Request(url, headers={"User-Agent": "AVP-League-Scraper/1.0"})
            with urllib.request.urlopen(request, timeout=60) as response:
                return response.read().decode("utf-8", errors="replace")
        except Exception as error:
            last_error = error
            if attempt + 1 < retries:
                import time

                time.sleep(2 * (attempt + 1))
    raise last_error  # type: ignore[misc]


def strip_tags(text: str) -> str:
    text = unescape(re.sub(r"<[^>]+>", "", text))
    return re.sub(r"\s+", " ", text).strip()


def team_id_from_name(name: str) -> str:
    cleaned = name.split(":")[0].strip()
    if cleaned not in TEAM_NAME_TO_ID:
        raise ValueError(f"Unknown team name: {name}")
    return TEAM_NAME_TO_ID[cleaned]


def parse_week(event: str) -> int:
    if "Championship" in event:
        return 9
    match = re.search(r"League Week\s+(\d+)", event)
    if not match:
        raise ValueError(f"Could not parse week from event: {event}")
    return int(match.group(1))


def parse_date(raw: str, season_year: int) -> tuple[int, int]:
    month, day = raw.split("/")
    return int(month), int(day)


def parse_result(result_html: str) -> tuple[int, int, list[tuple[int, int]]]:
    text = strip_tags(result_html)
    score_match = re.search(r"(\d+)-(\d+)", text)
    if not score_match:
        raise ValueError(f"Could not parse result score: {text}")
    team_sets_won = int(score_match.group(1))
    opponent_sets_won = int(score_match.group(2))

    sets_match = re.search(r"\(([^)]+)\)", text)
    if not sets_match:
        raise ValueError(f"Could not parse set scores: {text}")

    sets: list[tuple[int, int]] = []
    for part in sets_match.group(1).split(","):
        left, right = part.strip().split("-")
        sets.append((int(left), int(right)))

    return team_sets_won, opponent_sets_won, sets


def parse_pair(raw: str) -> dict[str, str]:
    player1, player2 = [part.strip() for part in raw.split("/", 1)]
    return {"player1": player1, "player2": player2}


def extract_team_pairs(html: str) -> tuple[dict[str, str], dict[str, str]]:
    table_starts = [
        match.start()
        for match in re.finditer(r'id="[^"]*dgAVPLeagueResults"', html, re.IGNORECASE)
    ]
    if len(table_starts) < 2:
        raise RuntimeError("Expected men's and women's league result tables on team page")

    pairs: list[dict[str, str]] = []
    for start in table_starts[:2]:
        chunk = html[:start]
        names = re.findall(r'class="clsTeamName"[^>]*>([^<]+)</td>', chunk, re.IGNORECASE)
        if not names:
            raise RuntimeError("Could not find pair name before league results table")
        pairs.append(parse_pair(names[-1]))

    return pairs[0], pairs[1]


def extract_league_tables(html: str) -> list[str]:
    pattern = re.compile(
        r'<table[^>]*id="[^"]*dgAVPLeagueResults"[^>]*>(.*?)</table>',
        re.IGNORECASE | re.DOTALL,
    )
    return pattern.findall(html)


def parse_table_rows(table_html: str, season_year: int, team_id: str, division: str) -> list[ScrapedRow]:
    row_pattern = re.compile(r"<tr[^>]*>(.*?)</tr>", re.IGNORECASE | re.DOTALL)
    cell_pattern = re.compile(r"<td[^>]*>(.*?)</td>", re.IGNORECASE | re.DOTALL)

    rows: list[ScrapedRow] = []
    for row_html in row_pattern.findall(table_html):
        if "clsHeadLine" in row_html:
            continue

        cells = cell_pattern.findall(row_html)
        if len(cells) < 8:
            continue

        date_raw = strip_tags(cells[0])
        if "/" not in date_raw:
            continue
        event = strip_tags(cells[1])
        opponent_raw = strip_tags(cells[4])
        result_html = cells[7]

        month, day = parse_date(date_raw, season_year)
        week = parse_week(event)
        venue = VENUE_BY_WEEK[season_year].get(week, event.split("-", 1)[-1].strip())
        opponent_id = team_id_from_name(opponent_raw)
        team_sets_won, opponent_sets_won, sets = parse_result(result_html)

        rows.append(
            ScrapedRow(
                season_year=season_year,
                team_id=team_id,
                division=division,
                month=month,
                day=day,
                week=week,
                venue=venue,
                opponent_id=opponent_id,
                team_sets_won=team_sets_won,
                opponent_sets_won=opponent_sets_won,
                sets=sets,
            )
        )

    return rows


def season_team_links(season_year: int) -> list[tuple[str, str]]:
    html = fetch(f"http://bvbinfo.info/AVPLeague?Season={season_year}")
    links = re.findall(r"AVPLeagueTeam\?TeamID=(\d+)[^>]*>([^<]+)</a>", html)
    seen: set[str] = set()
    teams: list[tuple[str, str]] = []
    for team_id, team_name in links:
        name = team_name.strip()
        if name not in TEAM_NAME_TO_ID or name in seen:
            continue
        seen.add(name)
        teams.append((team_id, TEAM_NAME_TO_ID[name]))
    return teams


def match_key(row: ScrapedRow) -> tuple:
    pair = tuple(sorted((row.team_id, row.opponent_id)))
    return (row.season_year, row.week, row.division, pair[0], pair[1], row.month, row.day)


def orient_match(row: ScrapedRow) -> dict:
    home_id, away_id = sorted((row.team_id, row.opponent_id))
    if row.team_id == home_id:
        sets = [{"homePoints": h, "awayPoints": a} for h, a in row.sets]
    else:
        sets = [{"homePoints": a, "awayPoints": h} for h, a in row.sets]

    return {
        "seasonYear": row.season_year,
        "weekNumber": row.week,
        "month": row.month,
        "day": row.day,
        "homeTeamID": home_id,
        "awayTeamID": away_id,
        "venue": row.venue,
        "division": row.division,
        "sets": sets,
    }


def assign_hours(matches: list[dict]) -> None:
    grouped: dict[tuple, list[dict]] = {}
    for match in matches:
        key = (match["seasonYear"], match["weekNumber"], match["month"], match["day"])
        grouped.setdefault(key, []).append(match)

    for group in grouped.values():
        group.sort(key=lambda m: (m["division"], m["homeTeamID"], m["awayTeamID"]))
        for index, match in enumerate(group):
            match["hour"] = HOURS[min(index, len(HOURS) - 1)]


def extract_championship_results(season_year: int) -> list[dict]:
    html = fetch(f"http://bvbinfo.info/AVPLeague?Season={season_year}")
    table_match = re.search(r'id="dgChampionships".*?</table>', html, re.IGNORECASE | re.DOTALL)
    if not table_match:
        return []

    rows = re.findall(
        r"<td>(Champions|2nd Place|3rd Place|4th Place)</td>\s*<td>.*?>([^<]+)</a>",
        table_match.group(),
        re.IGNORECASE | re.DOTALL,
    )
    if not rows:
        return []

    label_to_place = {
        "Champions": 1,
        "2nd Place": 2,
        "3rd Place": 3,
        "4th Place": 4,
    }

    results: list[dict] = []
    for label, team_name in rows:
        cleaned = team_name.strip()
        if cleaned not in TEAM_NAME_TO_ID:
            raise ValueError(f"Unknown championship team name: {cleaned}")
        results.append(
            {
                "place": label_to_place[label],
                "teamID": TEAM_NAME_TO_ID[cleaned],
            }
        )

    return sorted(results, key=lambda row: row["place"])


def build_season(season_year: int) -> tuple[list[dict], list[dict]]:
    collected: dict[tuple, dict] = {}
    teams: list[dict] = []

    for bvb_team_id, team_id in season_team_links(season_year):
        html = fetch(f"http://bvbinfo.info/AVPLeagueTeam?TeamID={bvb_team_id}&Season={season_year}")
        mens_pair, womens_pair = extract_team_pairs(html)
        teams.append(
            {
                "teamID": team_id,
                "mensPair": mens_pair,
                "womensPair": womens_pair,
            }
        )

        tables = extract_league_tables(html)
        if len(tables) < 2:
            raise RuntimeError(f"Expected 2 league tables for team {team_id} in {season_year}")

        for division, table_html in zip(("men", "women"), tables[:2]):
            for row in parse_table_rows(table_html, season_year, team_id, division):
                key = match_key(row)
                if key not in collected:
                    collected[key] = orient_match(row)

    teams.sort(key=lambda team: team["teamID"])
    matches = list(collected.values())
    assign_hours(matches)

    def sort_key(match: dict) -> tuple:
        return (match["weekNumber"], match["month"], match["day"], match["hour"], match["division"])

    matches.sort(key=sort_key)

    output: list[dict] = []
    counters: dict[tuple[int, str], int] = {}

    for match in matches:
        prefix = str(season_year)[-2:]
        week = match["weekNumber"]
        counter_key = (week, match["division"])
        counters[counter_key] = counters.get(counter_key, 0) + 1
        suffix = "F" if match["division"] == "women" else "M"
        match_id = f"{prefix}-w{week:02d}-{suffix}{counters[counter_key]:02d}-{match['homeTeamID']}-{match['awayTeamID']}"

        output.append(
            {
                "id": match_id,
                "seasonYear": match["seasonYear"],
                "weekNumber": match["weekNumber"],
                "month": match["month"],
                "day": match["day"],
                "hour": match["hour"],
                "homeTeamID": match["homeTeamID"],
                "awayTeamID": match["awayTeamID"],
                "venue": match["venue"],
                "division": match["division"],
                "status": "completed",
                "sets": match["sets"],
            }
        )

    return teams, output


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for season_year in (2024, 2025):
        print(f"Scraping {season_year}...")
        teams, matches = build_season(season_year)
        championship = extract_championship_results(season_year)
        output_path = OUTPUT_DIR / f"{season_year}.json"
        payload = {
            "seasonYear": season_year,
            "source": "http://bvbinfo.info/AVPLeague",
            "scrapedAt": datetime.utcnow().isoformat() + "Z",
            "teams": teams,
            "matches": matches,
        }
        if championship:
            payload["championshipResults"] = championship
        output_path.write_text(json.dumps(payload, indent=2))
        print(
            f"  Wrote {len(teams)} teams, {len(matches)} matches"
            f"{f', {len(championship)} championship finishes' if championship else ''} to {output_path}"
        )


if __name__ == "__main__":
    main()
