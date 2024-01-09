PRAGMA SYNCHRONOUS = OFF;

--
-- CREATE TABLE
--

CREATE TABLE `ACCOUNTS` (
    `ID`                INTEGER         NOT NULL,
    `NAME`              TEXT            NOT NULL COLLATE NOCASE,
    `PASSWORD`          TEXT            NOT NULL,
    `MONEY`             INTEGER         NOT NULL DEFAULT 500,
    `SCORE`             INTEGER         NOT NULL DEFAULT 0,
    `SKIN_ID`           INTEGER         NOT NULL,
    `INTERIOR_ID`       INTEGER         NOT NULL DEFAULT 0,
    `WORLD_ID`          INTEGER         NOT NULL DEFAULT 0,
    `WANTED_LEVEL`      INTEGER         NOT NULL DEFAULT 0,
    `HEALTH`            REAL            NOT NULL DEFAULT 100.0,
    `ARMOUR`            REAL            NOT NULL DEFAULT 0.0,
    `JOB_ID`            INTEGER         NOT NULL DEFAULT 0,
    `ADMIN_LEVEL`       INTEGER         NOT NULL DEFAULT 0,
    `HUNGER`            REAL            NOT NULL DEFAULT 100.0,
    `THIRST`            REAL            NOT NULL DEFAULT 100.0,
    `ENERGY`            REAL            NOT NULL DEFAULT 100.0,
    `X`                 REAL            NOT NULL DEFAULT 0.0,
    `Y`                 REAL            NOT NULL DEFAULT 0.0,
    `Z`                 REAL            NOT NULL DEFAULT 0.0,
    `A`                 REAL            NOT NULL DEFAULT 0.0,
    `CREATED_AT`        INTEGER       	NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `UPDATED_AT`        INTEGER       	NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID` AUTOINCREMENT)
);

--
-- INDEX
--

CREATE INDEX 
    `INDEX_ACCOUNT_NAME` 
ON 
    `ACCOUNTS` (`NAME`);
