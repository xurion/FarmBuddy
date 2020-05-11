# FFXI FarmBuddy

An addon for Final Fantasy XI that tracks item drops for all enemies and calculates drop rate percentages.

_Note: This was one of my first addons and was used as a learning experience. Therefore this is not built in the best way, albeit it does do the job._

Abbreviation: //fb, //farmbuddy

## Commands

### report

List all mobs killed with their drops and drop rates.

### reset

Resets all farm data.

### pause

Pauses tracking of farm data.

### resume

Resumes tracking of farm data.

### status

Displays status of FarmBuddy. Can be either "paused" or "running".

## Development

As a concept, this addon was developed using test-driven development. To run tests: `docker-compose run tests`.
