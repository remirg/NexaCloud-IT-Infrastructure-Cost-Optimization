
/*
==================================================================================================================
                Author:        Regina McDonald                                                                    
                Created Date:  10-07-2026                                                                       
                Description:   Scripts to Create NexaCloud Infrastructure Database and the 7 associated tables. 
==================================================================================================================
*/

/*
=================================================================================================================
               Creation of NexaCloud_Infrastructure database
=================================================================================================================
*/

CREATE DATABASE NexaCloud_Infrastructure;
USE NexaCloud_Infrastructure;

/*
=================================================================================================================
               Creation of the Departments Table with Associated Data
=================================================================================================================
*/

CREATE TABLE departments (
	department_id			INT PRIMARY KEY,
	department_name			VARCHAR(50) NOT NULL UNIQUE,
	manager_name			VARCHAR(100) NOT NULL,
	monthly_budget          DECIMAL (12,2) NOT NULL,
	cost_center				VARCHAR(15) NOT NULL UNIQUE,
	department_status		VARCHAR(20) NOT NULL DEFAULT 'Active'
);

INSERT INTO departments
	(department_id, department_name, manager_name, monthly_budget, cost_center, department_status)
VALUES
	(101, 'Engineering',      'Thomas Okonkwo-Reyes',   412750.00, 'CC-ENG-4171', 'Active'),
    (102, 'Data & Analytics', 'Mary Vantreese',        186300.00, 'CC-DNA-4283', 'Active'),
	(103, 'Finance',          'Ingrid Kalashan',       97450.00, 'CC-FIN-4319', 'Active'),
	(104, 'Marketing',        'Dorian Pelletier-Shaw', 158925.00, 'CC-MKT-4456', 'Under Review'),
	(105, 'Operations',       'Yashan Abernathy',      223600.00, 'CC-OPS-4528', 'Active'),
	(106, 'Customer Support', 'Caleb Ferreira-Nakamura', 134180.00, 'CC-CSP-4672', 'Restructuring');
    
 /*
=================================================================================================================
               Creation of the Cloud_Providers Table with Associated Data
=================================================================================================================
*/
    
CREATE TABLE cloud_providers (
	provider_id				INT PRIMARY KEY,
    provider_name			VARCHAR(50) NOT NULL UNIQUE,
    provider_type			VARCHAR(40) NOT NULL,
    billing_currency		CHAR(3) 	NOT NULL,
    contract_type			VARCHAR(40) NOT NULL,
    active_status			VARCHAR (20) NOT NULL DEFAULT 'Active'
);


INSERT INTO cloud_providers
	(provider_id, provider_name, provider_type, billing_currency, contract_type, active_status)
VALUES
	(201, 'Amazon Web Services', 'Public Cloud - IaaS', 'USD', 'Enterprise Discount Program', 'Active'),
    (202, 'Microsoft Azure', 'Public Cloud - PaaS', 'USD', 'Enterprise Agreement', 'Active'),
    (203, 'Google Cloud Platform', 'Public Cloud - Data & AI', 'EUR', 'Committed Use Discont', 'Pending Renewal');
    
/*
=================================================================================================================
               Creation of the Resource_Types Table with Associated Data
=================================================================================================================
*/

CREATE TABLE resource_types (
	resource_type_id		INT PRIMARY KEY,
    resource_type_name		VARCHAR(50) NOT NULL UNIQUE,
    resource_category		VARCHAR(30) NOT NULL,
    unit_of_measurement		VARCHAR(30) NOT NULL,
    description				VARCHAR(255)
    );
 
 INSERT INTO resource_types
	(resource_type_id, resource_type_name, resource_category, unit_of_measurement, description)
VALUES
(301, 'Virtual Machine',             'Compute',         'vCPU-Hour',      'On-demand virtual servers used to run applications, internal tools, and test environments.'),
(302, 'Object Storage',              'Storage',         'GB-Month',       'Scalable storage for files, backups, logs, and archived documents, billed by average monthly volume.'),
(303, 'Managed Relational Database', 'Database',        'vCore-Hour',     'Fully managed SQL database service with automated backups, patching, and failover.'),
(304, 'Outbound Data Transfer',      'Networking',      'GB Transferred', 'Data sent from the cloud environment out to the internet or to other regions.'),
(305, 'Serverless Query Engine',     'Data Processing', 'TB Scanned',     'Pay-per-query analytics service that charges for the volume of data each query reads.');
	
/*
===================================================================================================================================================================
               Creation of the Infrastructure_Resources Table with Associated Data
===================================================================================================================================================================
*/

CREATE TABLE infrastructure_resources (
	resource_id						INT PRIMARY KEY,
    resource_name				VARCHAR(60) 	NOT NULL UNIQUE,
    resource_type_id			INT 			NOT NULL,
    provider_id					INT				NOT NULL,
    department_id				INT				NOT NULL,
    provisioned_capacity		DECIMAL(12,2)	NOT NULL,
    creation_date				DATE			NOT NULL,
    resource_status				VARCHAR(25)		NOT NULL DEFAULT 'Running',
    FOREIGN KEY (resource_type_id) REFERENCES Resource_Types(resource_type_id),
    FOREIGN KEY (provider_id)	   REFERENCES Cloud_Providers (provider_id),
    FOREIGN KEY (department_id)	   REFERENCES Departments(department_id)
);

INSERT INTO Infrastructure_Resources
	(resource_id, resource_name, resource_type_id, provider_id, department_id, provisioned_capacity, creation_date, resource_status)
VALUES
    -- Engineering (eng)
    (401, 'eng-api-gateway-prod-vm',    301, 201, 101,    32.00, '2023-04-17', 'Running'),
    (402, 'eng-build-runner-vm',        301, 201, 101,    16.00, '2024-08-05', 'Running'),
    (403, 'eng-legacy-test-vm',         301, 202, 101,     8.00, '2023-11-20', 'Running'),
    (404, 'eng-code-artifacts-bucket',  302, 201, 101, 18000.00, '2023-02-09', 'Running'),
    (405, 'eng-orders-db-prod',         303, 201, 101,    16.00, '2023-06-28', 'Running'),
    (406, 'eng-cdn-egress',             304, 201, 101, 25000.00, '2024-01-15', 'Running'),
    -- Data & Analytics (dna)
    (407, 'dna-ml-training-vm',         301, 203, 102,    64.00, '2025-03-11', 'Running'),
    (408, 'dna-warehouse-query',        305, 203, 102,   120.00, '2024-05-22', 'Running'),
    (409, 'dna-raw-data-lake',          302, 203, 102, 85000.00, '2024-05-22', 'Running'),
    (410, 'dna-reporting-db',           303, 202, 102,     8.00, '2024-09-30', 'Running'),
    (411, 'dna-sandbox-notebook-vm',    301, 203, 102,    16.00, '2026-08-18', 'Running'),
    (412, 'dna-adhoc-query-engine',     305, 201, 102,    15.00, '2025-10-02', 'Running'),
    -- Finance (fin)
    (413, 'fin-erp-app-vm',             301, 202, 103,     8.00, '2023-01-12', 'Running'),
    (414, 'fin-ledger-db',              303, 202, 103,     4.00, '2023-01-12', 'Running'),
    (415, 'fin-audit-archive',          302, 202, 103,  4500.00, '2023-03-03', 'Running'),
    (416, 'fin-forecast-query',         305, 202, 103,     2.00, '2025-07-14', 'Stopped'),
    -- Marketing (mkt)
    (417, 'mkt-website-vm',             301, 201, 104,     4.00, '2024-02-26', 'Running'),
    (418, 'mkt-campaign-assets',        302, 201, 104, 12000.00, '2024-02-26', 'Running'),
    (419, 'mkt-crm-sync-db',            303, 203, 104,     8.00, '2025-01-09', 'Running'),
    (420, 'mkt-video-egress',           304, 203, 104,  9000.00, '2025-04-21', 'Running'),
    (421, 'mkt-spring-promo-vm',        301, 201, 104,    16.00, '2026-03-02', 'Running'),
    -- Operations (105)
    (422, 'ops-inventory-app-vm',       301, 202, 105,    16.00, '2023-09-14', 'Running'),
    (423, 'ops-warehouse-iot-db',       303, 202, 105,    12.00, '2024-04-08', 'Running'),
    (424, 'ops-backup-vault',           302, 202, 105, 40000.00, '2023-09-14', 'Running'),
    (425, 'ops-site-vpn-transfer',      304, 202, 105,  3000.00, '2023-10-30', 'Running'),
    (426, 'ops-logistics-analytics',    305, 203, 105,     8.00, '2025-11-17', 'Running'),
    -- Customer Support (csp)
    (427, 'csp-helpdesk-vm',            301, 202, 106,     8.00, '2024-06-03', 'Running'),
    (428, 'csp-ticket-history-db',      303, 201, 106,     4.00, '2024-06-03', 'Stopped'),
    (429, 'csp-call-recordings',        302, 201, 106, 22000.00, '2024-07-19', 'Running'),
    (430, 'csp-chatbot-old-vm',         301, 201, 106,     4.00, '2023-08-08', 'Pending Decommission');
    
 /*
==================================================================================================================================================================
               Creation of the Resource_Usage Table with Associated Data
==================================================================================================================================================================
*/

CREATE TABLE Resource_Usage (
    usage_id                       INT PRIMARY KEY,
    resource_id                    INT           NOT NULL,
    usage_date                     DATE          NOT NULL,
    cpu_utilization_percentage     DECIMAL(5,2)  NULL,
    memory_utilization_percentage  DECIMAL(5,2)  NULL,
    storage_used_gb                DECIMAL(12,2) NULL,
    processing_hours               DECIMAL(8,2)  NULL,
    network_usage_gb               DECIMAL(12,2) NULL,
    FOREIGN KEY (resource_id) REFERENCES Infrastructure_Resources(resource_id),
    UNIQUE (resource_id, usage_date),
    CHECK (cpu_utilization_percentage BETWEEN 0 AND 100),
    CHECK (memory_utilization_percentage BETWEEN 0 AND 100)
);

INSERT INTO Resource_Usage
    (usage_id, resource_id, usage_date, cpu_utilization_percentage, memory_utilization_percentage, storage_used_gb, processing_hours, network_usage_gb)
VALUES
    (501, 402, '2026-06-30', 71.30, 68.20, NULL, 610.00, 210.40),
    (502, 404, '2026-06-30', NULL, NULL, 11240.00, NULL, 320.50),
    (503, 406, '2026-06-30', NULL, NULL, NULL, NULL, 14200.00),
    (504, 407, '2026-06-30', 14.20, 22.50, NULL, 720.00, 540.30),
    (505, 408, '2026-06-30', NULL, NULL, NULL, 1840.00, NULL),
    (506, 409, '2026-06-30', NULL, NULL, 52300.00, NULL, 890.40),
    (507, 418, '2026-06-30', NULL, NULL, 6850.00, NULL, 410.30),
    (508, 420, '2026-06-30', NULL, NULL, NULL, NULL, 8450.00),
    (509, 424, '2026-06-30', NULL, NULL, 38900.00, NULL, 140.20),
    (510, 429, '2026-06-30', NULL, NULL, 12800.00, NULL, 55.20),
    (511, 430, '2026-06-30', 3.10, 8.20, NULL, 720.00, 2.10),
    (512, 401, '2026-07-31', 86.40, 82.10, NULL, 744.00, 1840.50),
    (513, 402, '2026-07-31', 78.60, 74.50, NULL, 688.00, 245.80),
    (514, 403, '2026-07-31', 1.20, 4.50, NULL, 744.00, 0.40),
    (515, 404, '2026-07-31', NULL, NULL, 12410.00, NULL, 355.20),
    (516, 405, '2026-07-31', 83.50, 89.20, 1420.00, 744.00, NULL),
    (517, 406, '2026-07-31', NULL, NULL, NULL, NULL, 16350.00),
    (518, 407, '2026-07-31', 11.80, 19.40, NULL, 744.00, 512.70),
    (519, 408, '2026-07-31', NULL, NULL, NULL, 2210.00, NULL),
    (520, 409, '2026-07-31', NULL, NULL, 58900.00, NULL, 1020.60),
    (521, 410, '2026-07-31', 12.40, 18.30, 210.00, 744.00, NULL),
    (522, 412, '2026-07-31', NULL, NULL, NULL, 64.00, NULL),
    (523, 413, '2026-07-31', 52.30, 58.60, NULL, 744.00, 145.20),
    (524, 414, '2026-07-31', 81.70, 78.40, 185.00, 744.00, NULL),
    (525, 415, '2026-07-31', NULL, NULL, 3120.00, NULL, 8.20),
    (526, 416, '2026-07-31', NULL, NULL, NULL, 0.00, NULL),
    (527, 417, '2026-07-31', 87.90, 76.40, NULL, 744.00, 610.40),
    (528, 418, '2026-07-31', NULL, NULL, 7720.00, NULL, 465.80),
    (529, 419, '2026-07-31', 9.80, 15.60, 96.00, 744.00, NULL),
    (530, 420, '2026-07-31', NULL, NULL, NULL, NULL, 7120.00),
    (531, 421, '2026-07-31', 0.90, 3.80, NULL, 744.00, 0.20),
    (532, 422, '2026-07-31', 84.60, 80.30, NULL, 744.00, 420.50),
    (533, 423, '2026-07-31', 62.40, 71.20, 2860.00, 744.00, NULL),
    (534, 424, '2026-07-31', NULL, NULL, 35200.00, NULL, 128.50),
    (535, 425, '2026-07-31', NULL, NULL, NULL, NULL, 1210.00),
    (536, 426, '2026-07-31', NULL, NULL, NULL, 410.00, NULL),
    (537, 427, '2026-07-31', 16.80, 24.60, NULL, 744.00, 62.40),
    (538, 428, '2026-07-31', 0.00, 0.00, 342.00, 0.00, NULL),
    (539, 429, '2026-07-31', NULL, NULL, 14350.00, NULL, 62.40),
    (540, 430, '2026-07-31', 1.40, 5.10, NULL, 744.00, 1.20),
    (541, 401, '2026-08-31', 88.90, 84.70, NULL, 744.00, 1912.30),
    (542, 402, '2026-08-31', 84.90, 81.00, NULL, 731.00, 288.10),
    (543, 403, '2026-08-31', 0.80, 4.30, NULL, 744.00, 0.30),
    (544, 404, '2026-08-31', NULL, NULL, 13685.00, NULL, 402.80),
    (545, 405, '2026-08-31', 86.10, 90.60, 1465.00, 744.00, NULL),
    (546, 406, '2026-08-31', NULL, NULL, NULL, NULL, 18900.00),
    (547, 407, '2026-08-31', 9.60, 17.80, NULL, 744.00, 498.20),
    (548, 408, '2026-08-31', NULL, NULL, NULL, 2690.00, NULL),
    (549, 409, '2026-08-31', NULL, NULL, 66150.00, NULL, 1180.20),
    (550, 410, '2026-08-31', 10.90, 17.10, 214.00, 744.00, NULL),
    (551, 411, '2026-08-31', 38.50, 41.20, NULL, 312.00, 45.20),
    (552, 412, '2026-08-31', NULL, NULL, NULL, 51.00, NULL),
    (553, 413, '2026-08-31', 54.10, 59.20, NULL, 744.00, 152.60),
    (554, 414, '2026-08-31', 84.20, 80.10, 188.00, 744.00, NULL),
    (555, 415, '2026-08-31', NULL, NULL, 3135.00, NULL, 6.50),
    (556, 416, '2026-08-31', NULL, NULL, NULL, 0.00, NULL),
    (557, 417, '2026-08-31', 90.30, 78.80, NULL, 744.00, 645.10),
    (558, 418, '2026-08-31', NULL, NULL, 8640.00, NULL, 520.20),
    (559, 419, '2026-08-31', 8.70, 14.90, 97.00, 744.00, NULL),
    (560, 420, '2026-08-31', NULL, NULL, NULL, NULL, 5880.00),
    (561, 421, '2026-08-31', 0.60, 3.50, NULL, 744.00, 0.10),
    (562, 422, '2026-08-31', 87.20, 82.60, NULL, 744.00, 438.20),
    (563, 423, '2026-08-31', 63.10, 72.00, 2875.00, 744.00, NULL),
    (564, 424, '2026-08-31', NULL, NULL, 31600.00, NULL, 115.30),
    (565, 425, '2026-08-31', NULL, NULL, NULL, NULL, 1185.00),
    (566, 426, '2026-08-31', NULL, NULL, NULL, 425.00, NULL),
    (567, 427, '2026-08-31', 15.20, 23.90, NULL, 744.00, 58.10),
    (568, 428, '2026-08-31', 0.00, 0.00, 342.00, 0.00, NULL),
    (569, 429, '2026-08-31', NULL, NULL, 16100.00, NULL, 70.10),
    (570, 430, '2026-08-31', 0.60, 3.90, NULL, 360.00, 0.40),
    (571, 401, '2026-09-30', 91.20, 87.30, NULL, 720.00, 1987.60),
    (572, 402, '2026-09-30', 92.40, 88.70, NULL, 720.00, 320.60),
    (573, 403, '2026-09-30', 1.10, 4.60, NULL, 720.00, 0.50),
    (574, 404, '2026-09-30', NULL, NULL, 15020.00, NULL, 446.10),
    (575, 405, '2026-09-30', 88.40, 92.10, 1512.00, 720.00, NULL),
    (576, 406, '2026-09-30', NULL, NULL, NULL, NULL, 21480.00),
    (577, 407, '2026-09-30', 12.30, 20.10, NULL, 720.00, 525.90),
    (578, 408, '2026-09-30', NULL, NULL, NULL, 3215.00, NULL),
    (579, 409, '2026-09-30', NULL, NULL, 73480.00, NULL, 1345.70),
    (580, 410, '2026-09-30', 11.60, 17.90, 219.00, 720.00, NULL),
    (581, 411, '2026-09-30', 57.90, 60.40, NULL, 720.00, 118.60),
    (582, 412, '2026-09-30', NULL, NULL, NULL, 39.00, NULL),
    (583, 413, '2026-09-30', 51.80, 57.90, NULL, 720.00, 148.30),
    (584, 414, '2026-09-30', 82.90, 79.60, 191.00, 720.00, NULL),
    (585, 415, '2026-09-30', NULL, NULL, 3150.00, NULL, 7.90),
    (586, 416, '2026-09-30', NULL, NULL, NULL, 0.00, NULL),
    (587, 417, '2026-09-30', 89.10, 77.50, NULL, 720.00, 628.70),
    (588, 418, '2026-09-30', NULL, NULL, 9580.00, NULL, 590.60),
    (589, 419, '2026-09-30', 10.20, 15.80, 99.00, 720.00, NULL),
    (590, 420, '2026-09-30', NULL, NULL, NULL, NULL, 4610.00),
    (591, 421, '2026-09-30', 0.70, 3.60, NULL, 720.00, 0.20),
    (592, 422, '2026-09-30', 85.90, 81.40, NULL, 720.00, 431.70),
    (593, 423, '2026-09-30', 61.80, 71.50, 2890.00, 720.00, NULL),
    (594, 424, '2026-09-30', NULL, NULL, 27850.00, NULL, 102.80),
    (595, 425, '2026-09-30', NULL, NULL, NULL, NULL, 1240.00),
    (596, 426, '2026-09-30', NULL, NULL, NULL, 418.00, NULL),
    (597, 427, '2026-09-30', 17.40, 25.10, NULL, 720.00, 65.30),
    (598, 428, '2026-09-30', 0.00, 0.00, 342.00, 0.00, NULL),
    (599, 429, '2026-09-30', NULL, NULL, 17920.00, NULL, 78.60),
    (600, 430, '2026-09-30', 0.00, 0.00, NULL, 0.00, 0.00);
 
 
 /*
==========================================================================================================================================================================
               Creation of the Infrastructure_Costs Table with Associated Data
==========================================================================================================================================================================
*/
    CREATE TABLE infrastructure_costs (
    cost_id        INT PRIMARY KEY,
    resource_id    INT           NOT NULL,
    billing_date   DATE          NOT NULL,
    compute_cost   DECIMAL(12,2) NULL,
    storage_cost   DECIMAL(12,2) NULL,
    network_cost   DECIMAL(12,2) NULL,
    database_cost  DECIMAL(12,2) NULL,
    other_cost     DECIMAL(12,2) NULL,
    FOREIGN KEY (resource_id) REFERENCES Infrastructure_Resources(resource_id),
    UNIQUE (resource_id, billing_date)
);

INSERT INTO infrastructure_costs
    (cost_id, resource_id, billing_date, compute_cost, storage_cost, network_cost, database_cost, other_cost)
VALUES
    (601, 402, '2026-06-30', 1232.20, 61.20, 17.88, NULL, 0.00),
    (602, 404, '2026-06-30', NULL, 258.52, 28.84, NULL, 11.20),
    (603, 406, '2026-06-30', NULL, NULL, 1207.00, NULL, NULL),
    (604, 407, '2026-06-30', 18440.00, 420.00, 64.84, NULL, 1150.00),
    (605, 408, '2026-06-30', 3956.00, NULL, NULL, NULL, 500.00),
    (606, 409, '2026-06-30', NULL, 1046.00, 71.23, NULL, NULL),
    (607, 418, '2026-06-30', NULL, 157.55, 34.88, NULL, NULL),
    (608, 420, '2026-06-30', NULL, NULL, 718.25, NULL, NULL),
    (609, 424, '2026-06-30', NULL, 700.20, 12.20, NULL, NULL),
    (610, 429, '2026-06-30', NULL, 294.40, 4.97, NULL, NULL),
    (611, 430, '2026-06-30', 280.80, 26.00, 0.19, NULL, NULL),
    (612, 401, '2026-07-31', 3844.00, 142.50, 156.44, NULL, 225.00),
    (613, 402, '2026-07-31', 1389.76, 61.20, 20.89, NULL, 0.00),
    (614, 403, '2026-07-31', 529.07, 38.40, 0.03, NULL, 0.00),
    (615, 404, '2026-07-31', NULL, 285.43, 31.97, NULL, 12.60),
    (616, 405, '2026-07-31', NULL, 163.30, NULL, 7078.33, 96.40),
    (617, 406, '2026-07-31', NULL, NULL, 1389.75, NULL, NULL),
    (618, 407, '2026-07-31', 19054.67, 420.00, 61.52, NULL, 1150.00),
    (619, 408, '2026-07-31', 4751.50, NULL, NULL, NULL, 500.00),
    (620, 409, '2026-07-31', NULL, 1178.00, 81.65, NULL, NULL),
    (621, 410, '2026-07-31', NULL, 24.15, NULL, 3534.00, NULL),
    (622, 412, '2026-07-31', 160.00, NULL, NULL, NULL, NULL),
    (623, 413, '2026-07-31', 661.33, 45.00, 12.63, NULL, 310.00),
    (624, 414, '2026-07-31', NULL, 21.28, NULL, 1767.00, NULL),
    (625, 415, '2026-07-31', NULL, 31.20, 0.71, NULL, NULL),
    (626, 416, '2026-07-31', 0.00, NULL, NULL, NULL, 18.00),
    (627, 417, '2026-07-31', 268.67, 18.40, 51.88, NULL, NULL),
    (628, 418, '2026-07-31', NULL, 177.56, 39.59, NULL, NULL),
    (629, 419, '2026-07-31', NULL, 16.32, NULL, 1694.67, NULL),
    (630, 420, '2026-07-31', NULL, NULL, 605.20, NULL, NULL),
    (631, 421, '2026-07-31', 1157.33, 52.00, 0.02, NULL, 0.00),
    (632, 422, '2026-07-31', 1322.67, 60.00, 36.58, NULL, NULL),
    (633, 423, '2026-07-31', NULL, 328.90, NULL, 5311.33, 80.00),
    (634, 424, '2026-07-31', NULL, 633.60, 11.18, NULL, NULL),
    (635, 425, '2026-07-31', NULL, NULL, 60.50, NULL, 138.00),
    (636, 426, '2026-07-31', 861.00, NULL, NULL, NULL, NULL),
    (637, 427, '2026-07-31', 661.33, 38.40, 5.43, NULL, 95.00),
    (638, 428, '2026-07-31', NULL, 39.33, NULL, 0.00, NULL),
    (639, 429, '2026-07-31', NULL, 330.05, 5.62, NULL, NULL),
    (640, 430, '2026-07-31', 290.16, 26.00, 0.11, NULL, NULL),
    (641, 401, '2026-08-31', 3937.00, 142.50, 162.55, NULL, 225.00),
    (642, 402, '2026-08-31', 1476.62, 61.20, 24.49, NULL, 0.00),
    (643, 403, '2026-08-31', 529.07, 38.40, 0.03, NULL, 0.00),
    (644, 404, '2026-08-31', NULL, 314.75, 36.25, NULL, 14.10),
    (645, 405, '2026-08-31', NULL, 168.47, NULL, 7078.33, 96.40),
    (646, 406, '2026-08-31', NULL, NULL, 1606.50, NULL, NULL),
    (647, 407, '2026-08-31', 19054.67, 420.00, 59.78, NULL, 1150.00),
    (648, 408, '2026-08-31', 5783.50, NULL, NULL, NULL, 500.00),
    (649, 409, '2026-08-31', NULL, 1323.00, 94.42, NULL, NULL),
    (650, 410, '2026-08-31', NULL, 24.61, NULL, 3534.00, NULL),
    (651, 411, '2026-08-31', 343.20, 28.00, 5.42, NULL, 0.00),
    (652, 412, '2026-08-31', 127.50, NULL, NULL, NULL, NULL),
    (653, 413, '2026-08-31', 661.33, 45.00, 13.28, NULL, 310.00),
    (654, 414, '2026-08-31', NULL, 21.62, NULL, 1767.00, NULL),
    (655, 415, '2026-08-31', NULL, 31.35, 0.57, NULL, NULL),
    (656, 416, '2026-08-31', 0.00, NULL, NULL, NULL, 18.00),
    (657, 417, '2026-08-31', 268.67, 18.40, 54.83, NULL, NULL),
    (658, 418, '2026-08-31', NULL, 198.72, 44.22, NULL, NULL),
    (659, 419, '2026-08-31', NULL, 16.49, NULL, 1694.67, NULL),
    (660, 420, '2026-08-31', NULL, NULL, 499.80, NULL, NULL),
    (661, 421, '2026-08-31', 1157.33, 52.00, 0.01, NULL, 0.00),
    (662, 422, '2026-08-31', 1322.67, 60.00, 38.12, NULL, NULL),
    (663, 423, '2026-08-31', NULL, 330.62, NULL, 5311.33, 80.00),
    (664, 424, '2026-08-31', NULL, 568.80, 10.03, NULL, NULL),
    (665, 425, '2026-08-31', NULL, NULL, 59.25, NULL, 138.00),
    (666, 426, '2026-08-31', 892.50, NULL, NULL, NULL, NULL),
    (667, 427, '2026-08-31', 661.33, 38.40, 5.05, NULL, 95.00),
    (668, 428, '2026-08-31', NULL, 39.33, NULL, 0.00, NULL),
    (669, 429, '2026-08-31', NULL, 370.30, 6.31, NULL, NULL),
    (670, 430, '2026-08-31', 140.40, 26.00, 0.04, NULL, NULL),
    (671, 401, '2026-09-30', 3905.00, 142.50, 168.95, NULL, 225.00),
    (672, 402, '2026-09-30', 1454.40, 61.20, 27.25, NULL, 0.00),
    (673, 403, '2026-09-30', 512.00, 38.40, 0.04, NULL, 0.00),
    (674, 404, '2026-09-30', NULL, 345.46, 40.15, NULL, 15.80),
    (675, 405, '2026-09-30', NULL, 173.88, NULL, 6850.00, 96.40),
    (676, 406, '2026-09-30', NULL, NULL, 1825.80, NULL, NULL),
    (677, 407, '2026-09-30', 18440.00, 420.00, 63.11, NULL, 1150.00),
    (678, 408, '2026-09-30', 6912.25, NULL, NULL, NULL, 500.00),
    (679, 409, '2026-09-30', NULL, 1469.60, 107.66, NULL, NULL),
    (680, 410, '2026-09-30', NULL, 25.19, NULL, 3420.00, NULL),
    (681, 411, '2026-09-30', 792.00, 28.00, 14.23, NULL, 0.00),
    (682, 412, '2026-09-30', 97.50, NULL, NULL, NULL, NULL),
    (683, 413, '2026-09-30', 640.00, 45.00, 12.90, NULL, 310.00),
    (684, 414, '2026-09-30', NULL, 21.96, NULL, 1710.00, NULL),
    (685, 415, '2026-09-30', NULL, 31.50, 0.69, NULL, NULL),
    (686, 416, '2026-09-30', 0.00, NULL, NULL, NULL, 18.00),
    (687, 417, '2026-09-30', 260.00, 18.40, 53.44, NULL, NULL),
    (688, 418, '2026-09-30', NULL, 220.34, 50.20, NULL, NULL),
    (689, 419, '2026-09-30', NULL, 16.83, NULL, 1640.00, NULL),
    (690, 420, '2026-09-30', NULL, NULL, 391.85, NULL, NULL),
    (691, 421, '2026-09-30', 1120.00, 52.00, 0.02, NULL, 0.00),
    (692, 422, '2026-09-30', 1280.00, 60.00, 37.56, NULL, NULL),
    (693, 423, '2026-09-30', NULL, 332.35, NULL, 5140.00, 80.00),
    (694, 424, '2026-09-30', NULL, 501.30, 8.94, NULL, NULL),
    (695, 425, '2026-09-30', NULL, NULL, 62.00, NULL, 138.00),
    (696, 426, '2026-09-30', 877.80, NULL, NULL, NULL, NULL),
    (697, 427, '2026-09-30', 640.00, 38.40, 5.68, NULL, 95.00),
    (698, 428, '2026-09-30', NULL, 39.33, NULL, 0.00, NULL),
    (699, 429, '2026-09-30', NULL, 412.16, 7.07, NULL, NULL),
    (700, 430, '2026-09-30', 0.00, 13.00, 0.00, NULL, NULL);
    
/*
======================================================================================================================================================================================
               Creation of the Optimization_Actions Table with Associated Data
======================================================================================================================================================================================
*/

CREATE TABLE optimization_actions (
    optimization_id        INT PRIMARY KEY,
    resource_id            INT           NOT NULL,
    action_date            DATE          NOT NULL,
    action_type            VARCHAR(30)   NOT NULL,
    previous_monthly_cost  DECIMAL(12,2) NOT NULL,
    new_monthly_cost       DECIMAL(12,2) NULL,
    action_status          VARCHAR(20)   NOT NULL,
    notes                  VARCHAR(255)  NULL,
    FOREIGN KEY (resource_id) REFERENCES Infrastructure_Resources(resource_id),
    CHECK (action_type IN ('Resize Resource','Delete Resource','Stop Idle Resource','Reduce Storage',
                           'Change Pricing Plan','Migrate Resource','Decommission Resource')),
    CHECK (action_status IN ('Planned','In Progress','Completed','Rejected'))
);

INSERT INTO optimization_actions
    (optimization_id, resource_id, action_date, action_type, previous_monthly_cost, new_monthly_cost, action_status, notes)

VALUES
    (701, 403, '2026-10-02', 'Delete Resource', 550.44, 0.00, 'Completed', 'Legacy test VM averaged ~1% CPU for 3 months. Owner confirmed it is no longer needed; final snapshot kept 30 days.'),
    (702, 421, '2026-10-01', 'Stop Idle Resource', 1172.02, 52.00, 'Completed', 'Spring promo ended in May but the VM kept running. Stopped; disk retained in case the campaign repeats.'),
    (703, 407, '2026-10-05', 'Resize Resource', 20073.11, 6250.00, 'In Progress', 'Avg CPU ~12% on 64 vCPUs. Downsizing to 16 vCPUs; large training jobs will run on-demand. Amounts in EUR.'),
    (704, 407, '2026-11-02', 'Change Pricing Plan', 6250.00, NULL, 'Planned', 'After the resize, evaluate a 1-year committed use discount. Waiting on Google quote.'),
    (705, 410, '2026-10-14', 'Resize Resource', 3445.19, 880.00, 'Planned', 'CPU ~11%. Downsize from 8 to 2 vCores after quarter-end reporting finishes.'),
    (706, 416, '2026-09-22', 'Delete Resource', 18.00, 0.00, 'Completed', NULL),
    (707, 419, '2026-11-16', 'Migrate Resource', 1656.83, NULL, 'Planned', 'Move CRM sync DB from Google Cloud to Azure to sit with the other marketing apps. Savings estimate pending.'),
    (708, 427, '2026-09-18', 'Resize Resource', 779.08, NULL, 'Rejected', 'Helpdesk vendor requires a minimum of 8 vCPUs for support coverage. Revisit at contract renewal.'),
    (709, 428, '2026-10-21', 'Decommission Resource', 39.33, 3.42, 'Planned', 'Stopped since July. Export ticket history to archive storage first (7-year retention) before deleting the database.'),
    (710, 430, '2026-08-16', 'Decommission Resource', 316.27, 13.00, 'In Progress', 'Chatbot replaced. VM shut down mid-August; final disk snapshot deletion still pending.'),
    (711, 404, '2026-10-06', 'Reduce Storage', 401.41, 220.00, 'In Progress', 'Storage up ~34% since June. Lifecycle rule now deletes build artifacts older than 90 days.'),
    (712, 429, '2026-10-20', 'Reduce Storage', 419.23, 120.00, 'Planned', 'Recordings grow every month. Move anything older than 60 days to archive tier.'),
    (713, 408, '2026-11-02', 'Change Pricing Plan', 7412.25, 5400.00, 'Planned', 'Query spend up ~75% since June and pushing Data & Analytics over budget. Switch on-demand to capacity commitment. Amounts in EUR.'),
    (714, 405, '2026-10-01', 'Change Pricing Plan', 7120.28, 4410.00, 'Completed', 'Highly utilized (86-88% CPU), so no resize. Savings come from a 1-year reserved instance.'),
    (715, 424, '2026-06-10', 'Reduce Storage', 790.00, 510.24, 'Completed', 'Backup retention cut from 365 to 90 days; old backups purged in monthly batches through September.');  
   