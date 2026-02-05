-- Function to add a report to event totals
-- This function updates the event_totals table with report data

CREATE OR REPLACE FUNCTION add_report_to_event_total(
    reportId TEXT,
    cluster TEXT,
    eventId TEXT,
    data JSONB
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    existing_record RECORD;
BEGIN
    -- Check if an event total record already exists for this event
    SELECT * INTO existing_record
    FROM event_totals
    WHERE "eventid" = eventId
    LIMIT 1;

    IF FOUND THEN
        -- Update existing record by adding the report data
        UPDATE event_totals
        SET
            "reportsid" = array_append("reportsid", reportId),
            "headcountfaculty" = "headcountfaculty" + COALESCE((data->>'headCountFaculty')::INTEGER, 0),
            "headcountadminmember" = "headcountadminmember" + COALESCE((data->>'headCountadminMember')::INTEGER, 0),
            "headcountrepsmember" = "headcountrepsmember" + COALESCE((data->>'headCountRepsMember')::INTEGER, 0),
            "headcountcustodian" = "headcountcustodian" + COALESCE((data->>'headCountCustodian')::INTEGER, 0),
            "headcountstudent" = "headcountstudent" + COALESCE((data->>'headCountStudent')::INTEGER, 0),
            "headcountsecurity" = "headcountsecurity" + COALESCE((data->>'headCountSecurity')::INTEGER, 0),
            "headcountconstructionworker" = "headcountconstructionworker" + COALESCE((data->>'headCountConstructionWorker')::INTEGER, 0),
            "headcounthealthworker" = "headcounthealthworker" + COALESCE((data->>'headCountHealthWorker')::INTEGER, 0),
            "headcountguest" = "headcountguest" + COALESCE((data->>'headCountGuest')::INTEGER, 0),
            "nummissingperson" = "nummissingperson" + COALESCE((data->>'numMissingPerson')::INTEGER, 0),
            "numcasualty" = "numcasualty" + COALESCE((data->>'numCasualty')::INTEGER, 0),
            "updatedat" = NOW()
        WHERE "eventid" = eventId;
    ELSE
        -- Insert new record
        INSERT INTO event_totals (
            "eventid",
            "cluster",
            "reportsid",
            "headcountfaculty",
            "headcountadminmember",
            "headcountrepsmember",
            "headcountramember",
            "headcountstudent",
            "headcountsecurity",
            "headcountconstructionworker",
            "headcounthealthworker",
            "headcountguest",
            "nummissingperson",
            "numcasualty",
            "createdat",
            "updatedat"
        ) VALUES (
            eventId,
            cluster,
            ARRAY[reportId],
            COALESCE((data->>'headCountFaculty')::INTEGER, 0),
            COALESCE((data->>'headCountadminMember')::INTEGER, 0),
            COALESCE((data->>'headCountRepsMember')::INTEGER, 0),
            COALESCE((data->>'headCountCustodian')::INTEGER, 0),
            COALESCE((data->>'headCountStudent')::INTEGER, 0),
            COALESCE((data->>'headCountSecurity')::INTEGER, 0),
            COALESCE((data->>'headCountConstructionWorker')::INTEGER, 0),
            COALESCE((data->>'headCountHealthWorker')::INTEGER, 0),
            COALESCE((data->>'headCountGuest')::INTEGER, 0),
            COALESCE((data->>'numMissingPerson')::INTEGER, 0),
            COALESCE((data->>'numCasualty')::INTEGER, 0),
            NOW(),
            NOW()
        );
    END IF;
END;
$$;
