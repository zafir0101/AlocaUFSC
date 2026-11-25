CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE USERS (
    id varchar(36),
    full_name varchar NOT NULL,
    email citext NOT NULL UNIQUE,
    password varchar NOT NULL,
    entity varchar NOT NULL,
    role varchar NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE VENUES (
    id varchar(36),
    code varchar NOT NULL,
    name varchar NOT NULL,
    center varchar NOT NULL,
    building varchar NOT NULL,
    capacity integer NOT NULL CHECK (capacity > 0 AND capacity <= 10000),
    description varchar,
    allowed_entities_mask integer NOT NULL CHECK (allowed_entities_mask BETWEEN 0 AND 15),
    PRIMARY KEY (id)
);

CREATE TABLE ALLOCATIONS (
    id varchar(36),
    venue_id varchar(36) NOT NULL,
    requester_id varchar(36) NOT NULL,
    start_time timestamp NOT NULL,
    end_time timestamp NOT NULL,
    status varchar NOT NULL,
    created_at timestamp NOT NULL,
    reviewer_id varchar(36),
    reviewed_at timestamp,
    rejection_reason varchar,
    PRIMARY KEY (id),
    FOREIGN KEY (venue_id) REFERENCES VENUES(id),
    FOREIGN KEY (requester_id) REFERENCES USERS(id),
    FOREIGN KEY (reviewer_id) REFERENCES USERS(id),
    CHECK (end_time > start_time)
);

CREATE TABLE EVENTS (
    id varchar(36),
    title varchar NOT NULL,
    description varchar,
    status varchar NOT NULL,
    allocation_id varchar(36),
    creator_id varchar(36) NOT NULL,
    period_start timestamp NOT NULL,
    period_end timestamp NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (allocation_id) REFERENCES ALLOCATIONS(id),
    FOREIGN KEY (creator_id) REFERENCES USERS(id),
    CHECK (period_end > period_start)
);

CREATE TABLE NOTIFICATIONS (
    id varchar(36),
    recipient_id varchar(36) NOT NULL,
    type varchar NOT NULL,
    message varchar NOT NULL,
    event_id varchar(36),
    created_at timestamp NOT NULL,
    is_read boolean NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (recipient_id) REFERENCES USERS(id),
    FOREIGN KEY (event_id) REFERENCES EVENTS(id)
);

CREATE INDEX IF NOT EXISTS idx_users ON USERS (id);
CREATE INDEX IF NOT EXISTS idx_events ON EVENTS (id);
CREATE INDEX IF NOT EXISTS idx_allocations ON ALLOCATIONS (id);
CREATE INDEX IF NOT EXISTS idx_notifications ON NOTIFICATIONS (id);
CREATE INDEX IF NOT EXISTS idx_venues ON VENUES (id);
