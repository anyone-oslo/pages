import React, { useState } from "react";

import DateRangeSelect from "../DateRangeSelect";

interface DatesProps {
  starts_at: Date | string;
  ends_at: Date | string;
  all_day: boolean;
}

export default function Dates(props: DatesProps) {
  const { starts_at, ends_at } = props;

  const [hasDates, setHasDates] = useState(props.starts_at ? true : false);
  const [allDay, setAllDay] = useState(!!props.all_day);

  const toggleHasDates = () => setHasDates(!hasDates);
  const toggleAllDay = () => setAllDay(!allDay);

  return (
    <div className="page-dates field">
      <input
        type="hidden"
        name="page[all_day]"
        value={hasDates && allDay ? "1" : "0"}
      />
      <label>Dates</label>
      <div className="toggles">
        <label className="has-dates-toggle">
          <input type="checkbox" checked={hasDates} onChange={toggleHasDates} />
          Enabled
        </label>
        <label className={!hasDates && "disabled"}>
          <input
            type="checkbox"
            disabled={!hasDates}
            checked={allDay}
            onChange={toggleAllDay}
          />
          All day event
        </label>
      </div>
      <DateRangeSelect
        objectName="page"
        startsAt={starts_at}
        endsAt={ends_at}
        disabled={!hasDates}
        disableTime={allDay}
      />
    </div>
  );
}
