# Mojarra Labs — Technical Submission Document

## Approach

This submission uses the competition repository's reference baseline. For each frame, it assigns
the ball to the team of the tracked player closest to the ball. It then applies a centered majority
vote over 50 frames on either side (about two seconds in each direction at 25 fps). If the window
contains no usable team observation, the output is `D`. Ties are assigned
to the home team (`H`).

This is a simple, deterministic baseline, not a custom-trained model or a new algorithm developed
by Mojarra Labs. We use the organizers' documented `baseline_smooth50` reference as a reproducible
starting point. The window was not selected by tuning against the public five-minute ground truth.

## Assets used

- Tactical automatic tracking data (ATD): player and ball locations used to find the nearest player.
- Tactical ATD metadata: track-to-team mapping used to convert the nearest player's track into `H`
  or `A`.

We did not use the tactical or broadcast video, homography, Smart Tagging, or external match data.
The baseline does not require these assets. Licensed match files are obtained separately under the
competition terms and are not included in this public repository.

## Training data

There is no model training and no labeled training dataset. The generator reads tracking data and
metadata only; it does not read public or private possession ground truth. No labels for this match
were created or corrected by hand. We ran the evaluator against the repository's public five-minute
ground truth to check the scoring pipeline; those scores were not used to tune the baseline. The
generator itself does not read any possession ground truth.

## Possession rules and limitations

The baseline treats the closest tracked player as having possession. It does not explicitly reason
about controlled touches, tackles, loose balls, restarts, or dead-ball events. `D` is emitted when
there is no team vote in the smoothing window; it is not a dedicated dead-ball detector. Smoothing
reduces frame-to-frame flicker but can delay or erase short possession changes. Tracking errors and
missing ball observations can therefore produce incorrect labels. This baseline is a documented
reference floor, not a claim of state-of-the-art performance.

## Reproduction

Requirements: Python 3.11 and the competition data bundle downloaded by an enrolled participant.
Keep the licensed bundle outside the public repository where possible. By default, the script
looks for the `tactical` directory under `data`. If the bundle is stored elsewhere, set
`MTAH_DATA_DIR` to the bundle root (the directory that contains `tactical`). Run the commands from
the repository root.

### Windows PowerShell

```powershell
py -3.11 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements-mojarra.txt
# Optional, only if the data bundle is stored outside the repository:
# $env:MTAH_DATA_DIR = "D:\path\to\mtah-data"
.\.venv\Scripts\python.exe starter\baseline.py --window 50 --output "..\Mojarra Labs.csv"
.\.venv\Scripts\python.exe evaluation\validate_submission.py "..\Mojarra Labs.csv"
```

### Linux or macOS

```bash
python3.11 -m venv .venv
. .venv/bin/activate
python -m pip install -r requirements-mojarra.txt
# Optional, only if the data bundle is stored outside ./data:
# export MTAH_DATA_DIR="/path/to/mtah-data"
python starter/baseline.py --window 50 --output "../Mojarra Labs.csv"
python evaluation/validate_submission.py "../Mojarra Labs.csv"
```

The generated CSV is written next to the repository folder, keeping the submission artifact out of
the public code repository. The validator checks the required header, labels, frame order, and
199,319-row length. It does not measure prediction quality.

## Validation and what the checks mean

The format validator above is the first required check. To verify that the scoring pipeline can
read the generated file, it may also be scored against the repository's public five-minute ground
truth. This is a pipeline sanity check only; the public sample is too small to select parameters or
predict the full-match ranking.

From the repository root in PowerShell:

```powershell
$publicResults = Join-Path $env:TEMP "mojarra-public-results"
$publicReport = Join-Path $env:TEMP "mojarra-public-report"
New-Item -ItemType Directory -Force $publicResults | Out-Null
Copy-Item -LiteralPath "..\Mojarra Labs.csv" `
  -Destination (Join-Path $publicResults "Mojarra Labs.csv") -Force
.\.venv\Scripts\python.exe evaluation\run_evaluation.py `
  --gt public --results $publicResults --out $publicReport
```

On Linux or macOS, use a temporary results directory so only this submission is scored:

```bash
mkdir -p /tmp/mojarra-public-results
cp "../Mojarra Labs.csv" "/tmp/mojarra-public-results/Mojarra Labs.csv"
python evaluation/run_evaluation.py --gt public \
  --results /tmp/mojarra-public-results --out /tmp/mojarra-public-report
```

The competition organizers determine the final score against the private full-match ground truth,
ranked by `spellF1`. That ground truth is not available to the team and must not be used to tune or
create labels. GitHub Actions checks the evaluation container and infrastructure configuration;
because licensed data is not stored in the public repository, CI does not regenerate this CSV.
