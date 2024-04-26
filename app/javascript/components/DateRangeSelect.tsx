import React, { useState } from "react";

import DateTimeSelect from "./DateTimeSelect";

interface DateRangeSelectProps {
  startsAt: Date | string;
  endsAt: Date | string;
  disabled: boolean;
  disableTime: boolean;
  objectName: string;
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

export default function DateRangeSelect(props: DateRangeSelectProps) {
  const { disabled, disableTime, objectName } = props;

  const [startsAt, setStartsAt] = useState(
    parseDate(props.startsAt) || defaultDate()
  );
  const [endsAt, setEndsAt] = useState(
    parseDate(props.endsAt) || defaultDate(60)
  );

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

  return (
    <div className="date-range-select">
      <div className="date">
        <DateTimeSelect
          name={objectName + "[starts_at]"}
          disabled={disabled}
          disableTime={disableTime}
          onChange={changeStartsAt}
          value={startsAt}
        />
      </div>
      <span className="to">to</span>
      <div className="date">
        <DateTimeSelect
          name={objectName + "[ends_at]"}
          disabled={disabled}
          disableTime={disableTime}
          onChange={changeEndsAt}
          value={endsAt}
        />
      </div>
    </div>
  );
}
