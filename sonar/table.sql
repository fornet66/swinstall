
drop table ssm_incre_issues;
create table ssm_incre_issues (
	department varchar(64) not null,
	project_name  varchar(64) not null,
	project_version  varchar(10) not null,
	module_name  varchar(32) not null,
	author  varchar(32) not null,
	file_name  varchar(255) not null,
	file_type  varchar(8) default 'java' not null,
	issue_name  varchar(4000),
	issue_line  int,
	issue_severity_name  varchar(32),
	rule_name  varchar(4000),
	issue_date  varchar(8) not null,
	MD5str  varchar(32) not null,
	primary key (MD5str)
);
create index idx_incre_issues1 on ssm_incre_issues (project_name);
create index idx_incre_issues2 on ssm_incre_issues (author);
create index idx_incre_issues3 on ssm_incre_issues (file_name, issue_date);

drop table ssm_incre_lines;
create table ssm_incre_lines (
	department varchar(64) not null,
	project_name  varchar(64) not null,
	project_version  varchar(10) not null,
	module_name  varchar(32) not null,
	author  varchar(32) not null,
	file_name  varchar(255) not null,
	file_lines int not null,
	file_type  varchar(8) default 'java' not null,
	issue_date varchar(8) not null,
	MD5str  varchar(32) not null,
	primary key (MD5str)
);
create index idx_incre_lines1 on ssm_incre_lines (project_name);
create index idx_incre_lines2 on ssm_incre_lines (author);
create index idx_incre_lines3 on ssm_incre_lines (file_name, issue_date);

drop table ssm_stat_issues;
create table ssm_stat_issues (
	department varchar(64) not null,
	project_name  varchar(64) not null,
	project_version  varchar(10) not null,
	module_name  varchar(32) not null,
	author  varchar(32) not null,
	file_name  varchar(255) not null,
	file_type  varchar(8) default 'java' not null,
	blocker_num int,
	critical_num int,
	major_num int,
	minor_num int,
	info_num  int,
	incre_blocker_num int,
	incre_critical_num int,
	incre_major_num int,
	incre_minor_num int,
	incre_info_num  int,
	stat_flag int default 0,
	stat_date varchar(8) not null
);
create index idx_stat_issues1 on ssm_stat_issues (department, project_name, author);
create index idx_stat_issues2 on ssm_stat_issues (stat_date);

drop table ssm_stat_lines;
create table ssm_stat_lines (
	department varchar(64) not null,
	project_name  varchar(64) not null,
	project_version  varchar(10) not null,
	module_name  varchar(32) not null,
	author  varchar(32) not null,
	file_name  varchar(255) not null,
	file_type  varchar(8) default 'java' not null,
	file_lines int,
	incre_file_lines int,
	stat_flag int default 0,
	stat_date varchar(8) not null
);
create index idx_stat_lines1 on ssm_stat_issues (department, project_name, author);
create index idx_stat_lines2 on ssm_stat_issues (stat_date);

