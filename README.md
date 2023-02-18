[![Build FG Extension](https://github.com/rhagelstrom/HighVariance/actions/workflows/create-release.yml/badge.svg)](https://github.com/rhagelstrom/HighVariance/actions/workflows/create-release.yml) [![Luacheckrc](https://github.com/rhagelstrom/HighVariance/actions/workflows/luacheck.yml/badge.svg)](https://github.com/rhagelstrom/HighVariance/actions/workflows/luacheck.yml)
# High Variance
High Variance is a FantasyGrounds extension for CoreRPG which changes the results of the dice to the more extreme end of the spectrum.

## Cursed Dice
All 20s on a d20 roll will be changed to 1

## Blessed Dice
All 1s on a d20 roll will be changed to 20

## Crit Fumble
All rolls on a d20 at or above the Critical Fumble Line will be changed to 20. All rolls below the Critical Fumble line will be changed to 1

## High Variance
The overall average of the result is the same but possible outcomes shifted to the extremes . Possible results on dice are as follows.
### d20
| | | | | | | | | | |  |  |  |  |  |  |  |  |  |  |
|-|-|-|-|-|-|-|-|-|-|--|--|--|--|--|--|--|--|--|--|
|1|1|1|2|2|3|3|4|5|6|15|16|17|18|18|19|19|20|20|20|

### d4
| | | | |
|-|-|-|-|
|1|1|4|4|

### d6
| | | | | | |
|-|-|-|-|-|-|
|1|1|2|5|6|6|

### d8
| | | | | | | | |
|-|-|-|-|-|-|-|-|
|1|1|2|3|6|7|8|8|

### d10
| | | | | | | | | | |
|-|-|-|-|-|-|-|-|-|-|
|1|1|2|2|3|8|9|9|0|0|

### d12
| | | | | | | |  |  |  |  |  |
|-|-|-|-|-|-|-|--|--|--|--|--|
|1|1|2|2|3|4|9|10|11|11|12|12|

## Global Settings
The global settings chan be changed in the settings menu

- **Dice Set** Dice set as described above or off (default)
- **Apply to Actors** Apply the dice set to all actors, friends only, foes only
- **Apply to Rolls**  Which rolls to apply to. DMG/HEAL only applies to High Variance dice set
- **CritFumble Line**  The value at which the Critical Fumble dice set determines success or failure

## Effects
Effects can be applied to indvidual actors and will override the global setting for this actor. Effects are formatted as follows

(label); HVROLL: (type); CRITLINE: (N)

**(label)** is type of one of the following:
- highvariance
- blesseddice
- curseddice
- critfumble

**HVROLL** is optional and will use the global setting if omitted. If used the type must be one of the following:
- all
- d20
- atkdmgheal
- dmgheal
- dmg

**CRITLINE** is optional and will use the global setting if omitted. If used the type must be a number between 1-19. Only applies to dice type critfumble

## Notes
- This extension does not change the graphical numbers displayed on the dice, only the results
- Changes in rolls only apply to rolls that have an actor source. Rolls not rolled from a character sheet will not be modified