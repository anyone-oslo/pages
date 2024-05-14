import React from "react";

import * as PageEditor from "../../types/PageEditor";

import DateRangeSelect from "../DateRangeSelect";

interface Props {
  state: PageEditor.State;
  dispatch: (action: PageEditor.Action) => void;
}

export default function Dates(props: Props) {
  const { state, dispatch } = props;
  const { datesEnabled, page } = state;

  const toggleAllDay = () => {
    dispatch({ type: "update", payload: { all_day: !page.all_day } });
  };

  const toggleDatesEnabled = () => {
    dispatch({ type: "setDatesEnabled", payload: !datesEnabled });
  };

  const setDate = (attr: "starts_at" | "ends_at") => (date: Date) => {
    dispatch({ type: "update", payload: { [attr]: date } });
  };

  return (
    <div className="page-dates field">
      <input
        type="hidden"
        name="page[all_day]"
        value={datesEnabled && page.all_day ? "1" : "0"}
      />
      <label>Dates</label>
      <div className="toggles">
        <label className="has-dates-toggle">
          <input
            type="checkbox"
            checked={datesEnabled}
            onChange={toggleDatesEnabled}
          />
          Enabled
        </label>
        <label className={!datesEnabled && "disabled"}>
          <input
            type="checkbox"
            disabled={!datesEnabled}
            checked={page.all_day}
            onChange={toggleAllDay}
          />
          All day event
        </label>
      </div>
      <DateRangeSelect
        objectName="page"
        startsAt={page.starts_at}
        setStartsAt={setDate("starts_at")}
        endsAt={page.ends_at}
        setEndsAt={setDate("ends_at")}
        disabled={!datesEnabled}
        disableTime={page.all_day}
      />
    </div>
  );
}
