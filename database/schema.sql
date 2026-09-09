
CREATE TABLE Organizations (
    OrganizationId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE Properties (
    PropertyId INT IDENTITY(1,1) PRIMARY KEY,
    OrganizationId INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    AddressLine1 NVARCHAR(150) NOT NULL,
    AddressLine2 NVARCHAR(150) NULL,
    City NVARCHAR(100) NOT NULL,
    StateCode CHAR(2) NOT NULL,
    PostalCode NVARCHAR(10) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Properties_Organizations
        FOREIGN KEY (OrganizationId)
        REFERENCES Organizations(OrganizationId)
);

CREATE TABLE Rooms (
    RoomId INT IDENTITY(1,1) PRIMARY KEY,
    PropertyId INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    FloorNumber INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Rooms_Properties
        FOREIGN KEY (PropertyId)
        REFERENCES Properties(PropertyId)
);

CREATE TABLE Beds (
    BedId INT IDENTITY(1,1) PRIMARY KEY,
    RoomId INT NOT NULL,
    Name NVARCHAR(50) NOT NULL,
    Status NVARCHAR(30) NOT NULL DEFAULT 'Vacant',
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Beds_Rooms
        FOREIGN KEY (RoomId)
        REFERENCES Rooms(RoomId)
);

CREATE TABLE Residents (
    ResidentId INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    PreferredName NVARCHAR(100) NULL,
    Email NVARCHAR(255) NULL,
    Phone NVARCHAR(30) NULL,
    DateOfBirth DATE NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE ResidentOrganizations (
    ResidentOrganizationId INT IDENTITY(1,1) PRIMARY KEY,
    ResidentId INT NOT NULL,
    OrganizationId INT NOT NULL,
    JoinedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    LeftAt DATETIME2 NULL,
    Status NVARCHAR(30) NOT NULL DEFAULT 'Active',
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_ResidentOrganizations_Residents
        FOREIGN KEY (ResidentId)
        REFERENCES Residents(ResidentId),

    CONSTRAINT FK_ResidentOrganizations_Organizations
        FOREIGN KEY (OrganizationId)
        REFERENCES Organizations(OrganizationId),

    CONSTRAINT CK_ResidentOrganizations_LeftAt
        CHECK (
            LeftAt IS NULL
            OR LeftAt >= JoinedAt
        )
);

CREATE UNIQUE INDEX UX_ResidentOrganizations_ActiveMembership
    ON ResidentOrganizations(ResidentId, OrganizationId)
    WHERE Status = 'Active';

CREATE TABLE Occupancies (
    OccupancyId INT IDENTITY(1,1) PRIMARY KEY,
    ResidentOrganizationId INT NOT NULL,
    BedId INT NOT NULL,
    MoveInDate DATE NOT NULL,
    MoveOutDate DATE NULL,
    Status NVARCHAR(30) NOT NULL DEFAULT 'Active',
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Occupancies_ResidentOrganizations
        FOREIGN KEY (ResidentOrganizationId)
        REFERENCES ResidentOrganizations(ResidentOrganizationId),

    CONSTRAINT FK_Occupancies_Beds
        FOREIGN KEY (BedId)
        REFERENCES Beds(BedId)
);

CREATE UNIQUE INDEX UX_Occupancies_ActiveBed
    ON Occupancies(BedId)
    WHERE Status = 'Active';

CREATE UNIQUE INDEX UX_Occupancies_ActiveResidentOrganization
    ON Occupancies(ResidentOrganizationId)
    WHERE Status = 'Active';

ALTER TABLE Occupancies
ADD CONSTRAINT CK_Occupancies_MoveOutDate
    CHECK (
        MoveOutDate IS NULL
        OR MoveOutDate >= MoveInDate
    );

CREATE TABLE Doors (
    DoorId INT IDENTITY(1,1) PRIMARY KEY,
    PropertyId INT NOT NULL,
    RoomId INT NULL,
    Name NVARCHAR(100) NOT NULL,
    DoorType NVARCHAR(30) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Doors_Properties
        FOREIGN KEY (PropertyId)
        REFERENCES Properties(PropertyId),

    CONSTRAINT FK_Doors_Rooms
        FOREIGN KEY (RoomId)
        REFERENCES Rooms(RoomId)
);

CREATE TABLE Credentials (
    CredentialId INT IDENTITY(1,1) PRIMARY KEY,
    ResidentOrganizationId INT NOT NULL,
    CredentialType NVARCHAR(30) NOT NULL,
    ExternalCredentialId NVARCHAR(255) NULL,
    Status NVARCHAR(30) NOT NULL DEFAULT 'Active',
    IssuedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    RevokedAt DATETIME2 NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Credentials_ResidentOrganizations
        FOREIGN KEY (ResidentOrganizationId)
        REFERENCES ResidentOrganizations(ResidentOrganizationId)
);

CREATE TABLE AccessAssignments (
    AccessAssignmentId INT IDENTITY(1,1) PRIMARY KEY,
    CredentialId INT NOT NULL,
    DoorId INT NOT NULL,
    AccessStatus NVARCHAR(30) NOT NULL DEFAULT 'Granted',
    GrantedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    RevokedAt DATETIME2 NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_AccessAssignments_Credentials
        FOREIGN KEY (CredentialId)
        REFERENCES Credentials(CredentialId),

    CONSTRAINT FK_AccessAssignments_Doors
        FOREIGN KEY (DoorId)
        REFERENCES Doors(DoorId)
);