SELECT 
md.`depo_id`,
md.`depo_name`,
IFNULL(rgm.rgm,'') AS rgm,
IFNULL(bm.bm,'') AS bm,
mc.`cust_name`,
vmct.cust_type_name,
-- Select tonase non colorount:
IFNULL(tonase_op_non_colourant,0) AS tonase_op_non_colourant ,
IFNULL(os_tonase_sj_non_colourant,0) AS os_tonase_sj_non_colourant ,
SUM(IFNULL(tonase_op_non_colourant,0) + IFNULL(os_tonase_sj_non_colourant,0)) AS total_tonase_os_non_colourant,
IFNULL(tonase_scan_sj_non_colourant,0) AS tonase_scan_sj_non_colourant,
IFNULL(tonase_fakur_non_colourant,0) AS tonase_fakur_non_colourant,
SUM(IFNULL(tonase_scan_sj_non_colourant,0) + IFNULL(tonase_fakur_non_colourant,0)) AS total_tonase_faktur_non_colourant,
-- Select tonase colorount:	
IFNULL(tonase_op_colourant,0) AS tonase_op_colourant ,
IFNULL(os_tonase_sj_colourant,0) AS os_tonase_sj_colourant,
SUM(IFNULL(tonase_op_colourant,0) + IFNULL(os_tonase_sj_colourant,0)) AS total_tonase_os_colourant,
IFNULL(tonase_scan_sj_colourant,0) AS tonase_scan_sj_colourant,
IFNULL(tonase_faktur_colorount,0) AS tonase_faktur_colorount,
SUM(IFNULL(tonase_scan_sj_colourant,0) + IFNULL(tonase_faktur_colorount,0)) AS total_tonase_faktur_colourant,
-- Select value non colorount:
IFNULL(os_value_op_non_colourant,0) AS os_value_op_non_colourant ,
IFNULL(os_value_sj_non_colourant,0) AS os_value_sj_non_colourant,
SUM(IFNULL(os_value_op_non_colourant,0) + IFNULL(os_value_sj_non_colourant,0)) AS total_value_os_non_colourant,
IFNULL(value_scan_sj_non_colourant,0) AS value_scan_sj_non_colourant,
IFNULL(value_faktur_non_colourant,0) AS value_faktur_non_colourant,
SUM(IFNULL(value_scan_sj_non_colourant,0) + IFNULL(value_faktur_non_colourant,0)) AS total_value_faktur_non_colourant,
-- Select tonase colorount:
IFNULL(os_value_op_colourant,0) AS os_value_op_colourant,
IFNULL(os_value_sj_colourant,0) AS  os_value_sj_colourant,
SUM(IFNULL(os_value_op_colourant,0) + IFNULL(os_value_sj_colourant,0)) AS total_value_os_colourant,
IFNULL(value_scan_sj_colourant,0) AS value_scan_sj_colourant,
IFNULL(faktur_colourant,0) AS faktur_colourant, 
SUM(IFNULL(value_scan_sj_colourant,0) + IFNULL(faktur_colourant,0)) AS total_value_faktur_colourant,
-- Select total tonase non colorount/colourant:
SUM(IFNULL(tonase_op_non_colourant,0) + IFNULL(tonase_op_colourant,0)) AS tonase_os_op,
SUM(IFNULL(os_tonase_sj_non_colourant,0) + IFNULL(os_tonase_sj_colourant,0)) AS tonase_os_sj,
IFNULL(tonase_scan_sj,0) AS tonase_scan_sj,
IFNULL(fnc.tonase_faktur,0) AS tonase_faktur,
SUM(IFNULL(scan_sj.tonase_scan_sj,0) + IFNULL(fnc.tonase_faktur,0)) AS total_tonase_faktur,
IFNULL(SUM(IFNULL(os_op,0) + IFNULL(os_sj,0)),0) AS total_tonase_os,
IFNULL(outstanding_op,0) AS outstanding_op,
IFNULL(outstanding_sj,0) AS outstanding_sj,
SUM(IFNULL(outstanding_op,0) + IFNULL(outstanding_sj,0)) AS total_os_value,
IFNULL(value_scan_sj,0) AS value_scan_js,
IFNULL(value_faktur,0) AS value_faktur,
SUM(IFNULL(value_scan_sj,0) + IFNULL(value_faktur,0)) AS total_value_faktur
FROM master_customers mc 
LEFT JOIN master_depo md ON mc.`depo_id` = md.`depo_id`
LEFT JOIN view_master_customer_types vmct	 ON mc.cust_id = vmct.`cust_id`
LEFT JOIN (
	SELECT 
	hed.emp_id AS emp_id,
	depo_id_list AS depo,
	mu.ug_name,
	me.emp_name AS bm
	FROM `history_employee_depo` hed
	JOIN `master_usergroups` mu ON mu.`ug_id` = hed.ug_id 
	LEFT JOIN `master_employees` me ON hed.emp_id = me.emp_id
	WHERE mu.`ug_short_name` = "BM" AND started_date <= CURDATE() AND (ended_date = 0 OR ended_date >= CURDATE())
	GROUP BY hed.emp_id
)AS bm ON md.`depo_id` =  bm.depo
LEFT JOIN(
	SELECT 
	hed.emp_id AS emp_id,
	depo_id_list AS depo,
	mu.ug_name,
	me.emp_name AS rgm
	FROM `history_employee_depo` hed
	JOIN `master_usergroups` mu ON mu.`ug_id` = hed.ug_id 
	LEFT JOIN `master_employees` me ON hed.emp_id = me.emp_id
	WHERE mu.`ug_short_name` = "RGM" AND started_date <= CURDATE() AND (ended_date = 0 OR ended_date >= CURDATE())
	GROUP BY hed.emp_id
)AS rgm ON FIND_IN_SET(md.depo_id,rgm.depo)
LEFT JOIN (
	SELECT
	op.`depo_id`,
	ms.`cust_id`, 
	SUM(CASE WHEN mic.`is_colourant` = 0 THEN ROUND((op_detail.`item_price` * op_detail.`remaining_amount`) - (op_detail.`item_price` * (op_detail.`disc_percent` / 100) * op_detail.`remaining_amount`)) ELSE 0 END) AS os_value_op_non_colourant,
	SUM(CASE WHEN mic.`is_colourant` = 0 THEN vmi.item_weight * op_detail.`remaining_amount` ELSE 0 END) AS tonase_op_non_colourant,
	SUM(CASE WHEN mic.`is_colourant` = 1 THEN ROUND((op_detail.`item_price` * op_detail.`remaining_amount`) - (op_detail.`item_price` * (op_detail.`disc_percent` / 100) * op_detail.`remaining_amount`)) ELSE 0 END) AS os_value_op_colourant,
	SUM(CASE WHEN mic.`is_colourant` = 1 THEN vmi.item_weight * op_detail.`remaining_amount` ELSE 0 END) AS tonase_op_colourant,
	SUM(CASE WHEN mic.`is_colourant` = 0 THEN ROUND((op_detail.`item_price` * op_detail.`remaining_amount`) - (op_detail.`item_price` * (op_detail.`disc_percent` / 100) * op_detail.`remaining_amount`)) ELSE 0 END) + SUM(CASE WHEN mic.`is_colourant` = 1 THEN ROUND((op_detail.`item_price` * op_detail.`remaining_amount`) - (op_detail.`item_price` * (op_detail.`disc_percent` / 100) * op_detail.`remaining_amount`)) ELSE 0 END) AS outstanding_op,
	ROUND(SUM(CASE WHEN mic.`is_colourant` = 0 THEN vmi.item_weight * op_detail.`remaining_amount` ELSE 0 END)  + 	SUM(CASE WHEN mic.`is_colourant` = 1 THEN vmi.item_weight * op_detail.`remaining_amount` ELSE 0 END),0) AS os_op
	FROM master_customers ms 
	JOIN master_depo md ON ms.`depo_id` = md.depo_id
	JOIN op ON ms.`cust_id` = op.`cust_id`
	JOIN op_detail USING(op_id)
	JOIN view_master_items vmi ON vmi.item_id = op_detail.`item_id`
	JOIN `master_item_classifications` mic ON vmi.`icf_id` = mic.`icf_id`
	WHERE op.`op_state` <=3 AND op_detail.`remaining_amount` > 0  AND op.`working_date` >= 20230501 AND op.`working_date` <= 20230531
	GROUP BY ms.`cust_id`
) AS op_non_c ON mc.cust_id = op_non_c.cust_id
LEFT JOIN(
	SELECT
  sj.`depo_id`,
  op.`cust_id`,
  SUM(CASE WHEN mic.`is_colourant` = 0 THEN ROUND((od.`item_price` * sjd.`remaining_amount`) - (od.`item_price` * (od.`disc_percent` / 100) * sjd.`remaining_amount`)) ELSE 0 END) AS os_value_sj_non_colourant,
  SUM(CASE WHEN mic.`is_colourant` = 0 THEN vmi.`item_weight` * sjd.remaining_amount ELSE 0 END) AS os_tonase_sj_non_colourant,
  SUM(CASE WHEN mic.`is_colourant` = 1 THEN ROUND((od.`item_price` * sjd.`remaining_amount`) - (od.`item_price` * (od.`disc_percent` / 100) * sjd.`remaining_amount`)) ELSE 0 END) AS os_value_sj_colourant,
  SUM(CASE WHEN mic.`is_colourant` = 1 THEN vmi.`item_weight` * sjd.remaining_amount ELSE 0 END) AS os_tonase_sj_colourant,
  SUM(CASE WHEN mic.`is_colourant` = 0 THEN ROUND((od.`item_price` * sjd.`remaining_amount`) - (od.`item_price` * (od.`disc_percent` / 100) * sjd.`remaining_amount`)) ELSE 0 END) + SUM(CASE WHEN mic.`is_colourant` = 1 THEN ROUND((od.`item_price` * sjd.`remaining_amount`) - (od.`item_price` * (od.`disc_percent` / 100) * sjd.`remaining_amount`)) ELSE 0 END) AS outstanding_sj,
  ROUND(SUM(CASE WHEN mic.`is_colourant` = 0 THEN vmi.`item_weight` * sjd.remaining_amount ELSE 0 END) + SUM(CASE WHEN mic.`is_colourant` = 1 THEN vmi.`item_weight` * sjd.remaining_amount ELSE 0 END),0) AS os_sj
	FROM sj_customer_detail sjd
	JOIN sj_customer sj USING(sjc_id)
	JOIN op ON sj.op_id = op.`op_id`
	JOIN op_detail od ON op.`op_id` = od.op_id AND sjd.item_id = od.item_id 
	JOIN view_master_items vmi ON vmi.item_id = od.`item_id`
	JOIN `master_item_classifications` mic ON vmi.`icf_id` = mic.`icf_id`
	WHERE sj.`is_sjc_finish` = 0 
	AND sjd.remaining_amount > 0 
	AND op.`working_date` >= 20230501 
	AND op.`working_date` <= 20230531 
	GROUP BY op.`cust_id`,mic.`is_tools`
)AS sj ON mc.`cust_id` = sj.cust_id
LEFT JOIN(
	SELECT 
	ssjc.depo_id,
	ssjc.cust_id,
  SUM(CASE WHEN mic.`is_colourant` = 0 THEN scjd.item_subtotal ELSE 0 END) AS value_scan_sj_non_colourant,
  SUM(CASE WHEN mic.`is_colourant` = 0 THEN scjd.amount * vmi.item_weight ELSE 0 END) AS tonase_scan_sj_non_colourant,
  SUM(CASE WHEN mic.`is_colourant` = 1 THEN scjd.item_subtotal ELSE 0 END) AS value_scan_sj_colourant,
  SUM(CASE WHEN mic.`is_colourant` = 1 THEN scjd.amount * vmi.item_weight ELSE 0 END) AS tonase_scan_sj_colourant,
  SUM(CASE WHEN mic.`is_colourant` = 1 THEN scjd.amount * vmi.item_weight ELSE 0 END) +  SUM(CASE WHEN mic.`is_colourant` = 0 THEN scjd.amount * vmi.item_weight ELSE 0 END) AS tonase_scan_sj,
	SUM(CASE WHEN mic.`is_colourant` = 0 THEN scjd.item_subtotal ELSE 0 END) + SUM(CASE WHEN mic.`is_colourant` = 1 THEN scjd.item_subtotal ELSE 0 END)  AS value_scan_sj
	FROM scan_sj_customer_detail scjd 
	JOIN scan_sj_customer ssjc USING(ssjc_id)
	JOIN `view_master_items` vmi ON scjd.item_id = vmi.`item_id`
	JOIN `master_item_classifications` mic ON vmi.`icf_id` = mic.`icf_id` 
	WHERE ssjc.ssjc_state != 99 AND ssjc_state <= 2 AND ssjc.`working_date` >= 20230501 AND ssjc.`working_date` <= 20230531
	GROUP BY ssjc.cust_id
)AS scan_sj ON mc.cust_id = scan_sj.cust_id
LEFT JOIN(
	SELECT
	mc.cust_id,
	mc.`depo_id`,
	SUM(CASE WHEN fj.`is_colourant` = 0 THEN fj.fj_total - IFNULL(rj.faktur_kurang,0) ELSE 0 END) AS value_faktur_non_colourant,
	SUM(CASE WHEN fj.`is_colourant` = 0 THEN fj.fj_tonase - IFNULL(rj.kurangin_tonase,0) ELSE 0 END) AS tonase_fakur_non_colourant,
	SUM(CASE WHEN fj.`is_colourant` = 1 THEN fj.fj_total - IF(rj.cust_id = fj.cust_id AND rj.is_colourant = fj.is_colourant, rj.faktur_kurang, 0)  ELSE 0 END) AS faktur_colourant ,
	SUM(CASE WHEN fj.`is_colourant` = 1 THEN fj.fj_tonase - IF(rj.cust_id = fj.cust_id AND rj.is_colourant = fj.is_colourant, rj.kurangin_tonase, 0) ELSE 0 END) AS tonase_faktur_colorount,
	SUM(CASE WHEN fj.`is_colourant` = 1 THEN fj.fj_tonase - IF(rj.cust_id = fj.cust_id AND rj.is_colourant = fj.is_colourant, rj.kurangin_tonase, 0) ELSE 0 END) + SUM(CASE WHEN fj.`is_colourant` = 0 THEN fj.fj_tonase - IFNULL(rj.kurangin_tonase,0) ELSE 0 END) AS tonase_faktur,
	SUM(CASE WHEN fj.`is_colourant` = 0 THEN fj.fj_total - IFNULL(rj.faktur_kurang,0) ELSE 0 END) + SUM(CASE WHEN fj.`is_colourant` = 1 THEN fj.fj_total - IF(rj.cust_id = fj.cust_id AND rj.is_colourant = fj.is_colourant, rj.faktur_kurang, 0)  ELSE 0 END) AS value_faktur
	FROM master_customers mc
	LEFT JOIN(
		SELECT 
		fj.fj_id,
		fj.cust_id,
		fj.depo_id,
		vmi.`icf_id`,
		mic.`is_colourant`,
		SUM(fjd.item_subtotal) AS fj_total,
		SUM(vmi.item_weight * fjd.amount) AS fj_tonase
		FROM faktur_jual_detail fjd
		JOIN faktur_jual fj USING(fj_id)
		JOIN `view_master_items` vmi ON fjd.item_id = vmi.item_id
		JOIN `master_item_classifications` mic ON vmi.icf_id = mic.icf_id
		WHERE fj.date_created >= 20230501 AND fj.date_created <= 20230531 
		GROUP BY fj.cust_id,mic.`is_colourant`
	)AS fj ON mc.cust_id = fj.cust_id 
	LEFT JOIN(
		SELECT 
		rj.cust_id, 
		rj.depo_id,
		vmi.icf_id,
		mic.`is_colourant`,
		SUM(IFNULL(rjd.total,0)) AS faktur_kurang,
		ROUND(SUM(IFNULL(vmi.`item_weight`,0) * IFNULL(rjd.amount,0)),4) AS kurangin_tonase
		FROM retur_jual_detail rjd 
		LEFT JOIN retur_jual rj USING(rj_id)
		LEFT JOIN view_master_items vmi ON rjd.item_id = vmi.item_id
		JOIN `master_item_classifications` mic ON vmi.icf_id = mic.icf_id
		WHERE rj.date_created >= 20230501 AND rj.date_created <= 20230531
		GROUP BY rj.depo_id ,rj.cust_id,mic.`is_colourant`	
	)AS rj ON mc.cust_id = rj.cust_id
	GROUP BY mc.cust_id 
)AS fnc ON mc.`cust_id` = fnc.cust_id
GROUP BY mc.cust_id,mc.`cust_code`,mc.`cust_name`;


