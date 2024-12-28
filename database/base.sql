PRAGMA SYNCHRONOUS = OFF;

--
-- CREATE TABLE
--

CREATE TABLE `ACCOUNTS` (
    `ID`                INTEGER         NOT NULL,
    `NAME`              TEXT            NOT NULL COLLATE NOCASE,
    `HASH`              TEXT            NOT NULL,
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
    `X`                 REAL            NOT NULL DEFAULT 0.0000,
    `Y`                 REAL            NOT NULL DEFAULT 0.0000,
    `Z`                 REAL            NOT NULL DEFAULT 3.1172,
    `A`                 REAL            NOT NULL DEFAULT 0.0000,
    `CREATED_AT`        DATETIME        NOT NULL DEFAULT (DATETIME('NOW', 'LOCALTIME')),
    `UPDATED_AT`        DATETIME        NOT NULL DEFAULT (DATETIME('NOW', 'LOCALTIME')),
    PRIMARY KEY (`ID` AUTOINCREMENT)
);

--
-- INDEX
--

CREATE INDEX 
    `INDEX_ACCOUNT_NAME` 
ON 
    `ACCOUNTS` (`NAME`);