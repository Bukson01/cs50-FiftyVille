-- Keep a log of any SQL queries you execute as you solve the mystery.

SELECT description FROM crime_scene_reports WHERE year = 2021 AND month = 7 AND day =28 AND street = "Humphrey Street";

/*
Theft of the CS50 duck took place at 10:15am at the Humphrey Street bakery. Interviews were conducted today with three witnesses who were present at the time – each of their interview transcripts mentions the bakery. Littering took place at 16:36. No known witnesses.
*/

SELECT name, transcript FROM interviews WHERE month = 7 AND day = 28 AND transcript LIKE "%bakery%";
/*
| Ruth    | Sometime within ten minutes of the theft, I saw the thief get into a car in the bakery parking lot and drive away. If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot in that time frame.                                                          |
| Eugene  | I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at Emma's bakery, I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money.                                                                                                 |
| Raymond | As the thief was leaving the bakery, they called someone who talked to them for less than a minute. In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow. The thief then asked the person on the other end of the phone to purchase the flight ticket.
*/

-- Following the first interview
SELECT name FROM people JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate WHERE day = "28" AND month = "7" AND year = "2021" AND hour = "10" AND minute >= "15" AND minute < "25" AND activity = "exit";

--Based on transcript of the second interview: Finding the names of the people who withdrew money from the ATM on Leggett St on the day of the theft.
SELECT DISTINCT name FROM people JOIN bank_accounts ON people.id = bank_accounts.person_id JOIN atm_transactions ON bank_accounts.account_number = atm_transactions.account_number WHERE day = "28" AND month = "7" AND year = "2021" AND transaction_type = "withdraw" AND atm_location = "Leggett Street";

-- Based on the transcript of the third interview: Finding the names of the people who bought the first flight ticket for the day after the theft.
SELECT name FROM people JOIN passengers ON people.passport_number = passengers.passport_number WHERE flight_id = (SELECT id FROM flights WHERE day = "29" AND month = "7" AND year = "2021" ORDER BY hour,minute LIMIT 1);

-- Based on the transcript of the third interview: Finding the names of the people who had call for less than a minute on the day of the theft.
SELECT name FROM people JOIN phone_calls ON people.phone_number = phone_calls.caller WHERE day = "28" AND month = "7" AND year = "2021" AND duration < "60";

-- Meet all the conditions to find the thief.
SELECT name FROM people JOIN passengers ON people.passport_number = passengers.passport_number WHERE flight_id = (SELECT id FROM flights WHERE day = "29" AND month = "7" AND year = "2021" ORDER By hour, minute LIMIT 1) INTERSECT SELECT DISTINCT name FROM people JOIN bank_accounts ON people.id = bank_accounts.person_id JOIN atm_transactions ON bank_accounts.account_number = atm_transactions.account_number WHERE day = "28" AND month = "7" AND year = "2021" AND transaction_type = "withdraw" AND atm_location = "Leggett Street" INTERSECT SELECT name FROM people JOIN phone_calls ON people.phone_number = phone_calls.caller WHERE day = "28" AND month = "7" AND year = "2021" AND duration < "60" INTERSECT SELECT name FROM people JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate WHERE day = "28" AND month = "7" AND year = "2021" AND hour = "10" AND minute >= "15" AND minute < "25" AND activity = "exit";

/* Name of the theif is Bruce*/

-- Suspect accomplice table
WITH suspect_accomplice_phone_number AS (
  SELECT receiver
  FROM phone_calls
  WHERE month = 7 AND day = 28
  AND caller = "(367) 555-5533"
  AND duration <= 60
)
SELECT *
FROM people
WHERE phone_number IN suspect_accomplice_phone_number;
/*
864400 | Robin | (375) 555-8161 |  | 4V16VO0
*/

SELECT *
FROM bakery_security_logs
WHERE month = 7 AND day = 28
AND license_plate IN ("V4C670D", "81MZ921", "4V16VO0", "10I5658");
/*
id | year | month | day | hour | minute | activity | license_plate
248 | 2021 | 7 | 28 | 8 | 50 | entrance | 4V16VO0
249 | 2021 | 7 | 28 | 8 | 50 | exit | 4V16VO0
*/


-- The thief escape to:
WITH earliest_flight_id AS (
  SELECT destination_airport_id
  FROM flights
  WHERE month = 7 AND day = 29
  AND origin_airport_id = (SELECT id FROM airports WHERE city = "Fiftyville")
  ORDER BY hour
  LIMIT 1
)
SELECT * FROM airports WHERE id IN earliest_flight_id;
/*
id | abbreviation | full_name | city
4 | LGA | LaGuardia Airport | New York City
*/