SELECT 
md.`depo_id`,
md.`depo_name`,
rgm.emp_name AS rgm,
bm.emp_name AS bm,
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
SUM((IFNULL(tonase_scan_sj_non_colourant,0) + IFNULL(tonase_scan_sj_colourant,0) + (IFNULL(tonase_fakur_non_colourant,0) + IFNULL(tonase_faktur_colorount,0)))) AS total_tonase_faktur,
ROUND(SUM((IFNULL(tonase_op_non_colourant,0) + IFNULL(tonase_op_colourant,0)) + (IFNULL(os_tonase_sj_non_colourant,0) + IFNULL(os_tonase_sj_colourant,0)))) AS total_tonase_os,
IFNULL(outstanding_op,0) AS outstanding_op,
IFNULL(outstanding_sj,0) AS outstanding_sj,
SUM((IFNULL(os_value_op_non_colourant,0) + IFNULL(os_value_op_colourant,0)) + (IFNULL(os_value_sj_non_colourant,0) + IFNULL(os_value_sj_colourant,0))) AS total_os_value,
IFNULL(value_scan_sj,0) AS value_scan_js,
IFNULL(SUM(value_faktur - IFNULL(vkturk.faktur_kurang,0)),0) AS value_faktur,
SUM(IFNULL(value_scan_sj,0) + IFNULL(value_faktur,0)) AS total_value_faktur
FROM master_customers mc 
LEFT JOIN master_depo md ON mc.`depo_id` = md.`depo_id`
LEFT JOIN view_master_customer_types vmct	 ON mc.cust_id = vmct.`cust_id`
LEFT JOIN (
	SELECT 
	msa.depo_id,
	IFNULL(hasil.ug_name,0) AS ug_name,
	IFNULL(me.emp_name,0) AS emp_name
	FROM master_sales_area msa
	JOIN (
		SELECT 
		IFNULL(hed.emp_id,0) AS emp_id,
		depo_id_list AS depo,
		mu.ug_name
		FROM `history_employee_depo` hed
		JOIN `master_usergroups` mu ON mu.`ug_id` = hed.ug_id 
		WHERE mu.`ug_short_name` = "BM" AND started_date <= CURDATE() + 0 AND (ended_date = 0 OR ended_date >= CURDATE() + 0)
		GROUP BY hed.emp_id
	)AS hasil ON FIND_IN_SET(msa.depo_id, hasil.depo)
	LEFT JOIN `master_employees` me ON hasil.emp_id = me.`emp_id`
	GROUP BY msa.depo_id
)AS bm ON md.`depo_id` = bm.depo_id
LEFT JOIN(
	SELECT 
	msa.depo_id,
	IFNULL(hasil.ug_name,0) AS ug_name,
	IFNULL(me.emp_name,0) AS emp_name
	FROM master_sales_area msa
	JOIN (
		SELECT 
		IFNULL(hed.emp_id,0) AS emp_id,
		depo_id_list AS depo,
		mu.ug_name
		FROM `history_employee_depo` hed
		JOIN `master_usergroups` mu ON mu.`ug_id` = hed.ug_id 
		WHERE mu.`ug_short_name` = "RGM" AND started_date <= CURDATE() + 0 AND (ended_date = 0 OR ended_date >= CURDATE() + 0)
		GROUP BY hed.emp_id
	)AS hasil ON FIND_IN_SET(msa.depo_id, hasil.depo)
	LEFT JOIN `master_employees` me ON hasil.emp_id = me.`emp_id`
	GROUP BY msa.depo_id
)AS rgm ON md.depo_id = rgm.depo_id
LEFT JOIN (
	SELECT
	op.`depo_id`,
	ms.`cust_id`, 
	SUM(CASE WHEN mic.`is_colourant` = 0 THEN ROUND((op_detail.`item_price` * op_detail.`remaining_amount`) - (op_detail.`item_price` * (op_detail.`disc_percent` / 100) * op_detail.`remaining_amount`)) ELSE 0 END) AS os_value_op_non_colourant,
	SUM(CASE WHEN mic.`is_colourant` = 0 THEN vmi.item_weight * op_detail.`remaining_amount` ELSE 0 END) AS tonase_op_non_colourant,
	SUM(CASE WHEN mic.`is_colourant` = 1 THEN ROUND((op_detail.`item_price` * op_detail.`remaining_amount`) - (op_detail.`item_price` * (op_detail.`disc_percent` / 100) * op_detail.`remaining_amount`)) ELSE 0 END) AS os_value_op_colourant,
	SUM(CASE WHEN mic.`is_colourant` = 1 THEN vmi.item_weight * op_detail.`remaining_amount` ELSE 0 END) AS tonase_op_colourant,
	SUM(CASE WHEN mic.`is_colourant` = 0 OR  mic.`is_colourant` = 1  THEN ROUND((op_detail.`item_price` * op_detail.`remaining_amount`) + (op_detail.`item_price` * (op_detail.`disc_percent` / 100) * op_detail.`remaining_amount`)) ELSE 0 END) AS outstanding_op
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
  SUM(CASE WHEN mic.`is_colourant` = 0 OR mic.`is_colourant` = 1 THEN ROUND((od.`item_price` * sjd.`remaining_amount`) + (od.`item_price` * (od.`disc_percent` / 100) * sjd.`remaining_amount`)) ELSE 0 END) AS outstanding_sj
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
	GROUP BY op.`cust_id`
)AS sj ON mc.`cust_id` = sj.cust_id
LEFT JOIN(
	SELECT 
	ssjc.depo_id,
	ssjc.cust_id,
  SUM(CASE WHEN mic.`is_colourant` = 0 THEN scjd.item_subtotal ELSE 0 END) AS value_scan_sj_non_colourant,
  SUM(CASE WHEN mic.`is_colourant` = 0 THEN scjd.amount * vmi.item_weight ELSE 0 END) AS tonase_scan_sj_non_colourant,
  SUM(CASE WHEN mic.`is_colourant` = 1 THEN scjd.item_subtotal ELSE 0 END) AS value_scan_sj_colourant,
  SUM(CASE WHEN mic.`is_colourant` = 1 THEN scjd.amount * vmi.item_weight ELSE 0 END) AS tonase_scan_sj_colourant,
  SUM(CASE WHEN mic.`is_colourant` = 1 THEN scjd.amount * vmi.item_weight ELSE 0 END) +  SUM(CASE WHEN mic.`is_colourant` = 0 THEN scjd.amount * vmi.item_weight ELSE 0 END) AS tonase_scan_sj
	FROM scan_sj_customer_detail scjd 
	JOIN `view_master_items` vmi ON scjd.item_id = vmi.`item_id`
	JOIN `master_item_classifications` mic ON vmi.`icf_id` = mic.`icf_id` 
	JOIN(
		SELECT 
		ssjc_id,
		sjc.`cust_id`,
		sjc.`depo_id`
		FROM scan_sj_customer ssjc JOIN sj_customer sjc USING(sjc_id) 
		WHERE ssjc.ssjc_state != 99 AND ssjc_state <= 2 AND ssjc.`working_date` >= 20230501 AND ssjc.`working_date` <= 20230531 
	)AS ssjc USING(ssjc_id)
	GROUP BY ssjc.cust_id
)AS scan_sj ON mc.cust_id = scan_sj.cust_id
LEFT JOIN(
	SELECT 
	ssjc.depo_id,
	ssjc.cust_id,
	SUM(item_subtotal) AS value_scan_sj,
	item_id,
	amount
	FROM scan_sj_customer_detail JOIN(
		SELECT 
		ssjc_id,
		sjc.`cust_id`,
		sjc.`depo_id`
		FROM scan_sj_customer ssjc JOIN sj_customer sjc USING(sjc_id) 
		WHERE ssjc.ssjc_state != 99 AND ssjc_state <= 2 AND ssjc.`working_date` >= 20230501 AND ssjc.`working_date` <= 20230531 
	)AS ssjc USING(ssjc_id)
	GROUP BY ssjc.cust_id
)AS vcsj ON mc.`cust_id` = vcsj.cust_id
LEFT JOIN(
	SELECT
	mc.cust_id,
	mc.`depo_id`,
	SUM(CASE WHEN fj.`is_colourant` = 0 THEN fj.fj_total - IFNULL(rj.faktur_kurang,0) ELSE 0 END) AS value_faktur_non_colourant,
	SUM(CASE WHEN fj.`is_colourant` = 0 THEN fj.fj_tonase - IFNULL(rj.kurangin_tonase,0) ELSE 0 END) AS tonase_fakur_non_colourant,
	SUM(CASE WHEN fj.`is_colourant` = 1 THEN fj.fj_total - IF(rj.cust_id = fj.cust_id AND rj.is_colourant = fj.is_colourant, rj.faktur_kurang, 0)  ELSE 0 END) AS faktur_colourant ,
	SUM(CASE WHEN fj.`is_colourant` = 1 THEN fj.fj_tonase - IF(rj.cust_id = fj.cust_id AND rj.is_colourant = fj.is_colourant, rj.kurangin_tonase, 0) ELSE 0 END) AS tonase_faktur_colorount,
	SUM(CASE WHEN fj.`is_colourant` = 1 THEN fj.fj_tonase - IF(rj.cust_id = fj.cust_id AND rj.is_colourant = fj.is_colourant, rj.kurangin_tonase, 0) ELSE 0 END) + SUM(CASE WHEN fj.`is_colourant` = 0 THEN fj.fj_tonase - IFNULL(rj.kurangin_tonase,0) ELSE 0 END) AS tonase_faktur
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
	)AS rj ON mc.cust_id = rj.cust_id WHERE mc.`depo_id` = 64
	GROUP BY mc.cust_id 
)AS fnc ON mc.`cust_id` = fnc.cust_id
LEFT JOIN (
	SELECT 
	fj.fj_id,
	fj.cust_id,
	fj.depo_id,
	fj.tpp_het,
	vmi.icf_id,
	fjd.`item_subtotal`,
	SUM(item_subtotal) AS value_faktur ,
	fjd.amount,
	fjd.item_id,
	SUM(vmi.`item_weight` * fjd.amount) AS tonase_faktur
	FROM faktur_jual_detail fjd
	JOIN faktur_jual fj USING(fj_id)
	JOIN view_master_items vmi ON fjd.item_id = vmi.item_id
	WHERE fj.date_created >= 20230501 AND fj.date_created <= 20230531 
  GROUP BY fj.cust_id
)AS vktur ON mc.`cust_id` = vktur.cust_id
LEFT JOIN(
	SELECT 
	rj.depo_id,
	vmi.icf_id,
	rj.cust_id, 
	SUM(IFNULL(rjd.total,0)) AS faktur_kurang,
	ROUND(SUM(IFNULL(vmi.`item_weight`,0) * IFNULL(rjd.amount,0)),4) AS kurangin_tonase
	FROM retur_jual_detail rjd 
	LEFT JOIN retur_jual rj USING(rj_id)
	LEFT JOIN view_master_items vmi USING(item_id)
	WHERE rj.date_created >= 20230501 AND rj.date_created <= 20230531
	GROUP BY rj.depo_id ,rj.cust_id
)AS vkturk ON mc.`cust_id` = vktur.cust_id
GROUP BY mc.cust_id,mc.`cust_code`,mc.`cust_name`


