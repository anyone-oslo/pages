import React, { useEffect, useState } from "react";

import DateTimeSelect from "./DateTimeSelect";

interface Props {
  objectName: string;
  startsAt: Date | string;
  endsAt: Date | string;
  setStartsAt?: (date: Date) => void;
  setEndsAt?: (date: Date) => void;
  disabled?: boolean;
  disableTime?: boolean;
}

function defaultDate(offset = 0): Date {
  const coeff = 1000 * 60 * 60;
  return new Date(
    Math.round(new Date().getTime() / coeff) * coeff +
      coeff +
      1000 * 60 * offset
  );
}

function parseDate(str: Date | string): Date {
  if (!str) {
    return null;
  } else if (typeof str === "string") {
    return new Date(str);
  } else {
    return str;
  }
}

export default function DateRangeSelect(props: Props) {
  const { disabled, disableTime, objectName } = props;

  const [uncontrolledStartsAt, setUncontrolledStartsAt] = useState(
    parseDate(props.startsAt)
  );

  const [uncontrolledEndsAt, setUncontrolledEndsAt] = useState(
    parseDate(props.endsAt) || defaultDate(60)
  );

  const startsAt = parseDate(
    props.setStartsAt ? props.startsAt : uncontrolledStartsAt
  );
  const setStartsAt = props.setStartsAt || setUncontrolledStartsAt;

  const endsAt = parseDate(props.setEndsAt ? props.endsAt : uncontrolledEndsAt);
  const setEndsAt = props.setEndsAt || setUncontrolledEndsAt;

  const setDates = (start: Date, end: Date) => {
    if (end < start) {
      end = start;
    }
    setStartsAt(start);
    setEndsAt(end);
  };

  const changeStartsAt = (newDate: Date) => {
    setDates(
      newDate,
      new Date(endsAt.getTime() + (newDate.getTime() - startsAt.getTime()))
    );
  };

  const changeEndsAt = (newDate: Date) => {
    setDates(startsAt, newDate);
  };

  useEffect(() => {
    if (!startsAt || !endsAt) {
      setDates(startsAt || defaultDate(), endsAt || defaultDate(60));
    }
  }, [startsAt, endsAt]);

  return (
    <div className="date-range-select">
      {startsAt && (
        <div className="date">
          <DateTimeSelect
            name={objectName + "[starts_at]"}
            disabled={disabled}
            disableTime={disableTime}
            onChange={changeStartsAt}
            value={startsAt}
          />
        </div>
      )}
      <span className="to">to</span>
      {endsAt && (
        <div className="date">
          <DateTimeSelect
            name={objectName + "[ends_at]"}
            disabled={disabled}
            disableTime={disableTime}
            onChange={changeEndsAt}
            value={endsAt}
          />
        </div>
      )}
    </div>
  );
}
