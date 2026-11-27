# Driver proposals: van seats and keep current (VAN-116)

## Why

The quote request, composer and negotiation screens left out seats and the
"keep current" action. The API already exposes the occupancy
(`GET /api/drivers/me/occupancy`).

## What changes

- Quote request: occupancy, vacancies and projected occupancy per requested shift.
- Composer: vacancies per requested shift under the van.
- Both only for drivers with a single van, because the API does not split
  contracted students by van.
- Adjustment screen: "Keep current" (opens the chat), "New version" and
  "End negotiation" (declines the request).

## Out of scope (no API support)

- Vanep commission and net amounts.
- Reservation fee deducted from the first installment.
