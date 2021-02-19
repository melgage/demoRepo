#COMMENT

SELECT
	 r.review_id AS `reviewid`
	,r.review_title AS `reviewtitle`
	,r.review_creationdate AS `reviewcreationdate`
	,r.review_phaseid AS `phase`
	,rAuthor.user_name AS `reviewauthorusername`
	,rReviewer.user_name AS `reviewreviewerusername`
	,rObserver.user_name AS `reviewobserverusername`
	,IFNULL(defect_summary.numDefects,0) AS `numdefects`
	,IFNULL(comment_summary.numComments,0) AS `numcomments`
	,IFNULL(comment_summary.comment_latest,r.review_creationdate) AS `comment_latest`
	,UNIX_TIMESTAMP('2020-09-17 21:25:25.217')-UNIX_TIMESTAMP(IFNULL(comment_summary.comment_latest,r.review_creationdate)) AS `review_idle`
	,SUM( metrics.filemetrics_lines ) AS `loc`
	,SUM( metrics.filemetrics_linesadded + metrics.filemetrics_linesremoved + metrics.filemetrics_linesmodified ) AS `locchanged`
	,SUM( metrics.filemetrics_linesadded ) AS `locadded`
	,SUM( metrics.filemetrics_linesremoved ) AS `locremoved`
	,SUM( metrics.filemetrics_linesmodified ) AS `locmodified`
	,SUM( metrics.filemetrics_linesdelta ) AS `locdelta`
	,act_summary.totalsecs AS `reviewpersonduration`
	,act_summary.reviewersecs AS `reviewerduration`
	,act_summary.authorsecs AS `authorduration`
	,numUsers.num_participants AS `numparticipants`
	,act_summary.totalsecs / numUsers.num_participants AS `averageduration`
	,mddv149.metadatavaluestringbig_value AS `overview`
FROM
	review r
LEFT JOIN metadatavaluestringbig mddv149 ON (mddv149.metadatavaluestringbig_fieldid=149 AND mddv149.metadatavaluestringbig_targetid=r.review_id)
LEFT JOIN (SELECT a.assignment_reviewid revid, IF((COUNT(u.user_id)= 1),MIN(u.user_name),'(multiple)') user_name, IF((COUNT(u.user_id)= 1),MIN(u.user_login),'(multiple)') user_login FROM assignment a INNER JOIN user u ON (a.assignment_userid=u.user_id) WHERE 3=a.assignment_roleid % 4 GROUP BY a.assignment_reviewid) rReviewer ON (rReviewer.revid = r.review_id)
LEFT JOIN ( SELECT d.defect_reviewid,COUNT(defect_id) numDefects,SUM(IF((d.defect_state)=('O'),1,0)) numOpenDefects FROM defect d GROUP BY d.defect_reviewid) defect_summary ON (defect_summary.defect_reviewid = r.review_id)
LEFT JOIN ( SELECT a.activity_reviewid,MIN(a.activity_startsecs) startsecs,MAX(a.activity_startsecs + a.activity_durationsecs) endsecs,SUM(a.activity_durationsecs) totalsecs,SUM(IF((a.activity_code)=('R'),a.activity_durationsecs,0)) reviewersecs,SUM(IF((a.activity_code)=('A'),a.activity_durationsecs,0)) authorsecs FROM activity a GROUP BY a.activity_reviewid) act_summary ON (act_summary.activity_reviewid = r.review_id)
LEFT JOIN (SELECT a.assignment_reviewid revid, IF((COUNT(u.user_id)= 1),MIN(u.user_name),'(multiple)') user_name, IF((COUNT(u.user_id)= 1),MIN(u.user_login),'(multiple)') user_login FROM assignment a INNER JOIN user u ON (a.assignment_userid=u.user_id) WHERE 0=a.assignment_roleid % 4 GROUP BY a.assignment_reviewid) rObserver ON (rObserver.revid = r.review_id)
LEFT JOIN (SELECT a.assignment_reviewid revid, IF((COUNT(u.user_id)= 1),MIN(u.user_name),'(multiple)') user_name, IF((COUNT(u.user_id)= 1),MIN(u.user_login),'(multiple)') user_login FROM assignment a INNER JOIN user u ON (a.assignment_userid=u.user_id) WHERE 2=a.assignment_roleid % 4 GROUP BY a.assignment_reviewid) rAuthor ON (rAuthor.revid = r.review_id)
LEFT JOIN ( SELECT c.comment_reviewid,SUM(IF((c.comment_type IN ('USER','ACPT','CMVD','RSYS','DCNV')),1,0)) numComments,MAX(comment_createdon) comment_latest FROM comment c WHERE c.comment_publishstate = 'sent' GROUP BY c.comment_reviewid) comment_summary ON (comment_summary.comment_reviewid = r.review_id)
 LEFT JOIN joinreviewchangelist jrc ON (jrc.joinreviewchangelist_reviewid = r.review_id)  LEFT JOIN changelist chg ON (chg.changelist_id = jrc.joinreviewchangelist_changelistid)  LEFT JOIN version v ON (v.version_changelistid = chg.changelist_id)  LEFT JOIN filemetrics metrics ON (metrics.filemetrics_versionid = v.version_id  AND v.version_filepath NOT LIKE '%.mdl'  AND v.version_filepath NOT LIKE '%.gif'  AND v.version_filepath NOT LIKE '%.jpg'  AND v.version_filepath NOT LIKE '%.jpeg'  AND v.version_filepath NOT LIKE '%.png'  AND v.version_filepath NOT LIKE '%.bmp'  AND v.version_filepath NOT LIKE 'ods'  AND v.version_filepath NOT LIKE '%.xls'  AND v.version_filepath NOT LIKE '%.xlsb'  AND v.version_filepath NOT LIKE '%.xlsm'  AND v.version_filepath NOT LIKE '%.xlsx'  AND v.version_filepath NOT LIKE '%.xltm'  AND v.version_filepath NOT LIKE '%.xltx'  AND v.version_localtype <> 'U'  ) LEFT JOIN (SELECT r.review_id review_id, count(a.assignment_userid) num_participants FROM review r INNER JOIN assignment a ON (r.review_id = a.assignment_reviewid) GROUP BY r.review_id) numUsers ON (r.review_id = numUsers.review_id)
WHERE
	    (r.review_phaseid=1 OR r.review_phaseid=8 OR r.review_phaseid=2 OR r.review_phaseid=3)
 GROUP BY r.review_id, r.review_title, r.review_creationdate, r.review_phaseid, rAuthor.user_name, rReviewer.user_name, rObserver.user_name, IFNULL(defect_summary.numDefects,0), IFNULL(comment_summary.numComments,0), IFNULL(comment_summary.comment_latest,r.review_creationdate), UNIX_TIMESTAMP('2020-09-17 21:25:25.217')-UNIX_TIMESTAMP(IFNULL(comment_summary.comment_latest,r.review_creationdate)), act_summary.totalsecs, act_summary.reviewersecs, act_summary.authorsecs, numUsers.num_participants, act_summary.totalsecs / numUsers.num_participants, mddv149.metadatavaluestringbig_value
ORDER BY
	 r.review_id DESC

