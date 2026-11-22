
import csv
from pathlib import Path


DATA_DIR = Path("ml-1m")
OUTPUT_DIR = Path("import")

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


def convert_file(source, destination, headers, columns=None):
    # Convert MovieLens DAT format into UTF-8 CSV
    count = 0

    with (
        (DATA_DIR / source).open(
            "r", encoding="latin-1"
        ) as source_file,
        (OUTPUT_DIR / destination).open(
            "w", newline="", encoding="utf-8"
        ) as target_file
    ):
        writer = csv.writer(target_file)
        writer.writerow(headers)

        for line in source_file:
            values = line.rstrip("\r\n").split("::")

            if columns is not None:
                values = values[:columns]

            writer.writerow(values)
            count += 1

    print(f"{destination}: {count} records")


def main():
    convert_file(
        "movies.dat",
        "movies.csv",
        ["movieId", "title", "genres"]
    )

    convert_file(
        "users.dat",
        "users.csv",
        ["userId", "gender", "age", "occupation"],
        columns=4
    )

    convert_file(
        "ratings.dat",
        "ratings.csv",
        ["userId", "movieId", "rating", "timestamp"]
    )

    print("\nConversion completed.")


if __name__ == "__main__":
    main()
