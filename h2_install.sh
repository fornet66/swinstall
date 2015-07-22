
java -jar h2-1.4.187.jar -webAllowOthers -tcpAllowOthers

CREATE TABLE  incre_issues (
 author  varchar(255) DEFAULT NULL,
 issue_name  varchar(4000) DEFAULT NULL,
 issue_line  varchar(255) DEFAULT NULL,
 issue_file_name  varchar(255) DEFAULT NULL,
 issue_severity_name  varchar(255) DEFAULT NULL,
 rule_name  varchar(4000) DEFAULT NULL,
 issue_date  varchar(255) DEFAULT NULL,
 province  varchar(255) DEFAULT NULL,
 project_name  varchar(255) DEFAULT NULL,
 module_name  varchar(255) DEFAULT NULL,
 project_version  varchar(255) DEFAULT NULL,
 MD5str  varchar(255) NOT NULL DEFAULT '',
 PRIMARY KEY ( MD5str )
);
create index idx_issue_line on incre_issues (issue_line);
create index idx_issue_date on incre_issues (issue_date);
create index idx_author on incre_issues (author);

