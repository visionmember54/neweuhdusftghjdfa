# Mobile API Integration — Sangam

The learner-facing Flutter application remains a separate workstream. This
document defines the ready-to-consume backend contract for Sangam support.

## Discovering availability

1. Fetch `GET /game-types`; active registry entries now include
   `HALF_SANGAM` and `FULL_SANGAM`.
2. Fetch `GET /markets/{market_id}/games` (or include `slot_id` for Starline).
   Only enabled game types are returned, so the app must use this response to
   decide whether to show a game.
3. Fetch `GET /markets/{market_id}/rates` for the current simulated rate.

## Submission payloads

All values are virtual Learning Credits. Submit one item with
`POST /simulations`, or use `POST /simulations/bulk` with identical fields in
each `selections[]` entry. User JWT authentication is required.

```json
{
  "market_id": 12,
  "game_type": "HALF_SANGAM",
  "value": "128-4",
  "game_variant": "OPEN_PANNA_CLOSE_ANK",
  "credits": 10
}
```

`HALF_SANGAM` always uses canonical `PANNA-ANK` input. `game_variant` is
required and must be one of:

- `OPEN_PANNA_CLOSE_ANK`: selection wins against `open_panna-close_ank`.
- `OPEN_ANK_CLOSE_PANNA`: selection wins against `close_panna-open_ank`.

The second identifier is retained for compatibility with the game catalogue;
the persisted input order is still `PANNA-ANK`, for example `470-1`.

```json
{
  "market_id": 12,
  "game_type": "FULL_SANGAM",
  "value": "128-470",
  "credits": 10
}
```

`FULL_SANGAM` uses canonical `OPEN_PANNA-CLOSE_PANNA` input and does not take
`game_variant`.

## Resolution and responses

Sangam entries remain `Pending` until both open and close panna results have
been published. Responses from creation and `GET /simulations/my` include
`gameVariant`, `status`, `simulatedReturn`, and the normal result metadata.
Do not calculate winners or payouts in the mobile client; display the API
status after result publication.
