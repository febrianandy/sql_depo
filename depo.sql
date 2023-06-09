SELECT 
d.depo_id,
d.depo_name,
IFNULL(bm.emp_name,0) AS bm,
IFNULL(rgm.emp_name,0) AS rgm,
IFNULL(os_qty_tools_op,0) AS os_qty_tools_op,
IFNULL(os_qty_tools_sj,0) AS os_qty_tools_sj,
IFNULL(value_scan_sj.qty_tools_scan_sj,0) AS qty_tools_scan_sj,
IFNULL(qty_tools_faktur,0) AS qty_tools_faktur,
IFNULL(SUM(os_qty_tools_op + IFNULL(os_qty_tools_sj,0) ),0) AS total_qty_tools,
IFNULL(os_tonase_op,0) AS os_tonase_op,
IFNULL(os_tonase_sj,0) AS os_tonase_sj,
IFNULL(SUM(IFNULL(os_tonase_op,0) + IFNULL(os_tonase_sj,0)),0) AS os_tonase,
IFNULL(tonase_scan_sj,0) AS tonase_scan_sj,
IFNULL(tonase_faktur,0) AS tonase_faktur,
IFNULL(SUM(tonase_scan_sj + IFNULL(tonase_faktur,0)),0) AS total_tonase,
IFNULL(os_value_op,0) AS os_value_op,
IFNULL(os_value_sj,0) AS os_value_sj,
IFNULL(value_scan_sj,0) AS value_scan_sj,
IFNULL(SUM(os_value_op + IFNULL(os_value_sj,0)),0) AS os_value,
IFNULL(os_value_sj,0) AS os_value_sj,
IFNULL(os_value_tools_op,0) AS os_value_tools_op,
IFNULL(os_value_tools_sj,0) AS os_value_tools_sj,
IFNULL(SUM(os_value_tools_op + IFNULL(os_value_tools_sj,0)),0) AS os_value_tools,
IFNULL(value_tools_scan_sj,0) AS value_tools_scan_sj ,
IFNULL(tools_value_faktur,0) AS tools_value_faktur ,
IFNULL(SUM(os_value_op + IFNULL(os_value_sj,0)),0) AS total_value_os,
IFNULL(total_scan_sj_before_tpp,0) AS total_scan_sj_before_tpp,
IFNULL(value_fakur_sebelum_tpp,0) AS value_fakur_sebelum_tpp,
IFNULL(SUM( total_scan_sj_before_tpp + IFNULL(value_fakur_sebelum_tpp,0)),0) AS total_value_sebelum_tpp,
IFNULL(value_scan_sj,0) AS value_ssjc,
IFNULL(value_faktur,0) AS value_faktur,
IFNULL(SUM(IFNULL(value_scan_sj,0) + IFNULL(value_faktur,0)),0) AS total_value
FROM master_depo d
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
		WHERE mu.`ug_short_name` = "BM" AND started_date <= CURRENT_DATE AND (ended_date = 0 OR ended_date >= CURRENT_DATE)
		GROUP BY hed.emp_id
	)AS hasil ON FIND_IN_SET(msa.depo_id, hasil.depo)
	LEFT JOIN `master_employees` me ON hasil.emp_id = me.`emp_id`
	GROUP BY msa.depo_id
)AS bm ON d.`depo_id` = bm.depo_id
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
		WHERE mu.`ug_short_name` = "RGM" AND started_date <= CURRENT_DATE AND (ended_date = 0 OR ended_date >= CURRENT_DATE)
		GROUP BY hed.emp_id
	)AS hasil ON FIND_IN_SET(msa.depo_id, hasil.depo)
	LEFT JOIN `master_employees` me ON hasil.emp_id = me.`emp_id`
	GROUP BY msa.depo_id
)AS rgm ON d.depo_id = rgm.depo_id
LEFT JOIN(
	SELECT
	op.`depo_id`,
	SUM(CASE WHEN mic.`is_tools` = 0 THEN ROUND((od.remaining_amount * od.item_price) - (od.item_price * (od.disc_percent / 100) * od.remaining_amount)) ELSE 0 END) AS os_value_op,
	SUM(CASE WHEN mic.`is_tools` = 0 THEN vma.`item_weight` * od.remaining_amount ELSE 0 END) AS os_tonase_op,
	SUM(CASE WHEN mic.`is_tools` = 1 THEN ROUND((od.remaining_amount * od.item_price) - (od.item_price * (od.disc_percent / 100) * od.remaining_amount)) ELSE 0 END) AS os_value_tools_op,
	SUM(CASE WHEN mic.`is_tools` = 1 THEN od.`remaining_amount` ELSE 0 END) AS os_qty_tools_op
	FROM op_detail od
	INNER JOIN op ON od.op_id = op.op_id
	JOIN view_master_items vma ON od.`item_id` = vma.`item_id`
	JOIN `master_item_classifications` mic ON vma.`icf_id` = mic.icf_id
	WHERE op.op_state <=3 AND op.`is_op_finish` = 0 AND od.remaining_amount > 0 AND op.`working_date` >= 20230501 AND op.`working_date` <= 20230531
	GROUP BY op.`depo_id`
)AS result_op_tools ON d.depo_id = result_op_tools.depo_id
LEFT JOIN( 
	SELECT
	op.`depo_id`,
	SUM(CASE WHEN mic.`is_tools` = 0 THEN ROUND(vmi.item_weight * sjd.remaining_amount,2) ELSE 0 END) AS os_tonase_sj,
	SUM(CASE WHEN mic.`is_tools` = 0 THEN ROUND((od.`item_price` * sjd.`amount`) - (od.`item_price` * (od.`disc_percent` / 100) * sjd.`amount`)) ELSE 0 END) AS os_value_sj,
	SUM(CASE WHEN mic.`is_tools` = 1 THEN ROUND((od.`item_price` * sjd.`amount`) - (od.`item_price` * (od.`disc_percent` / 100) * sjd.`amount`)) ELSE 0 END) AS os_value_tools_sj,
	SUM(CASE WHEN mic.`is_tools` = 1 THEN sjd.remaining_amount ELSE 0 END) AS os_qty_tools_sj
	FROM sj_customer_detail sjd
	JOIN sj_customer sjc  ON sjd.`sjc_id` = sjc.`sjc_id`
	JOIN op ON sjc.`op_id` = op.`op_id`
	JOIN view_master_items vmi ON vmi.item_id = sjd.`item_id`
	JOIN `master_item_classifications` mic ON vmi.`icf_id` = mic.`icf_id`
	JOIN op_detail od ON od.`op_id` = op.`op_id` AND od.`item_id` = sjd.`item_id`
	WHERE sjc.`is_sjc_finish` = 0 AND sjd.`remaining_amount` > 0 AND sjc.`working_date` >= 20230501 AND sjc.`working_date` <= 20230531
	GROUP BY op.`depo_id`
)AS value_sj ON d.depo_id = value_sj.depo_id
LEFT JOIN(
	SELECT 
	ssjc.depo_id,
	SUM(CASE WHEN mic.`is_tools` = 0 THEN sjcd.item_subtotal ELSE 0 END) AS value_scan_sj,
	SUM(CASE WHEN mic.`is_tools` = 0 THEN sjcd.amount * vmi.item_weight ELSE 0 END) AS tonase_scan_sj,
	SUM(CASE WHEN mic.`is_tools` = 1 THEN sjcd.item_subtotal ELSE 0 END) AS value_tools_scan_sj,
	SUM(CASE WHEN mic.`is_tools` = 1 THEN sjcd.amount ELSE 0 END) AS qty_tools_scan_sj
	FROM scan_sj_customer_detail sjcd
	JOIN `scan_sj_customer` ssjc ON sjcd.ssjc_id = ssjc.ssjc_id
	JOIN `view_master_items` vmi ON sjcd.`item_id` = vmi.`item_id`
	JOIN `master_item_classifications` mic ON vmi.`icf_id` = mic.`icf_id`
	WHERE ssjc.ssjc_state != 99 AND ssjc_state <=2 AND ssjc.`working_date` >= 20230501 AND ssjc.`working_date` <= 20230531 
	GROUP BY ssjc.depo_id			
)AS value_scan_sj ON d.`depo_id` = value_scan_sj.depo_id
LEFT JOIN(
	SELECT 
	md.depo_id,
	SUM(CASE WHEN fk.`is_tools` = 0 THEN fk.value_faktur - IFNULL(f_kurang.value_faktur_kurangin, fk.tpp_het) ELSE 0 END) AS value_faktur,
	SUM(CASE WHEN fk.`is_tools` = 0 THEN fk.tonase_faktur - IFNULL(f_kurang.kurangin_faktur_tonase,0) ELSE 0 END) AS tonase_faktur,
	SUM(CASE WHEN fk.`is_tools` = 1 THEN fk.value_faktur - IFNULL(f_kurang.value_faktur_kurangin, fk.tpp_het) ELSE 0 END) AS tools_value_faktur,
	SUM(CASE WHEN fk.`is_tools` = 1 THEN fk.qty_tools_faktur - IFNULL(f_kurang.qty_tools_f_kurang,0) ELSE 0 END) AS qty_tools_faktur
	FROM master_depo md 
	LEFT JOIN(
		SELECT 
		vmi.`item_weight`, 
		fjd.`amount`, 
		fj.depo_id,
		fj.tpp_het,
		mic.`is_tools`,
		IFNULL(SUM(fjd.item_subtotal),0) AS value_faktur,
		IFNULL(SUM(vmi.item_weight * fjd.amount),0) AS tonase_faktur,
		IFNULL(SUM(fjd.`amount`),0) AS qty_tools_faktur
		FROM faktur_jual_detail fjd
		JOIN faktur_jual fj USING(fj_id)
		JOIN view_master_items vmi USING(item_id)
		JOIN op USING(op_id)
		JOIN `master_item_classifications` mic ON vmi.`icf_id` = mic.`icf_id`
		WHERE op.`op_state` = 5 AND op.`working_date` >= 20230501 AND op.`working_date` <= 20230531
		GROUP BY fj.`depo_id`,mic.`is_tools`
	)AS fk ON md.depo_id = fk.depo_id
	LEFT JOIN(
		SELECT 
		depo_id,
		IFNULL(SUM(total),0) AS value_faktur_kurangin,
		IFNULL(SUM(vmi.item_weight * amount),0) AS kurangin_faktur_tonase,
		IFNULL(SUM(amount),0) AS qty_tools_f_kurang,
		item_id,
		item_weight
		FROM retur_jual_detail 
		JOIN retur_jual rj USING(rj_id)
		JOIN view_master_items vmi USING(item_id)
		JOIN `master_item_classifications` mic ON vmi.`icf_id` = mic.`icf_id` 
		WHERE rj.`date_created` >= 20230501 AND rj.`date_created` <= 20230531 
		GROUP BY depo_id,mic.`is_tools`
	)AS f_kurang ON md.depo_id = f_kurang.depo_id
	GROUP BY md.depo_id, md.depo_code, md.depo_name
)AS v_faktur ON d.depo_id = v_faktur.depo_id
LEFT JOIN( 
	SELECT 
	sjc.depo_id,
	SUM(ssjc.`total_before_tpp`) + IFNULL(hasil.total_tambahan,0) AS total_scan_sj_before_tpp
	FROM scan_sj_customer ssjc JOIN sj_customer sjc USING(sjc_id) 
	LEFT JOIN(
		SELECT
			depo_id,
			IFNULL(SUM(CASE WHEN total_before_tpp = 0 THEN item_subtotal ELSE total_before_tpp END),0) AS total_tambahan
			FROM op_detail JOIN(
			SELECT
			ssjd.item_id,
			sj_customer.op_id,
			ssjc.depo_id,
			ssjc.ssjc_id,
			total_before_tpp
			FROM scan_sj_customer_detail ssjd
			JOIN scan_sj_customer ssjc USING (ssjc_id)
			JOIN sj_customer USING (sjc_id)
			JOIN op ON sj_customer.op_id = op.op_id
			WHERE ssjc.working_date >= 20230501 AND ssjc.working_date <= 20230531 AND ssjc.ssjc_state != 99 AND ssjc.ssjc_state = 1 AND total_before_tpp = 0
		)AS result ON op_detail.op_id = result.op_id AND op_detail.item_id = result.item_id 
		GROUP BY depo_id
	)AS hasil ON ssjc.depo_id = hasil.depo_id WHERE ssjc.ssjc_state != 99 AND ssjc_state <=2 AND ssjc.`working_date` >= 20230501 AND ssjc.`working_date` <= 20230531 
	GROUP BY ssjc.`depo_id`
)AS result_scan_sj ON d.depo_id = result_scan_sj.depo_id
LEFT JOIN(
	SELECT 
	faktur_jual.depo_id,
	SUM(faktur_jual.total_before_tpp) - IFNULL(fb.kurangin,0) AS value_fakur_sebelum_tpp
	FROM faktur_jual 
	JOIN op USING(op_id) 
	LEFT JOIN( 
		SELECT 
		depo_id, 
		SUM(total) AS kurangin 
		FROM retur_jual_detail 
		JOIN retur_jual rj USING(rj_id)
		WHERE rj.`date_created` >= 20230501 AND rj.`date_created` <= 20230531 GROUP BY depo_id
	)AS fb ON faktur_jual.`depo_id` = fb.depo_id WHERE op.`op_state` = 5 AND op.`date_created` >= 20230501 AND op.`date_created` <= 20230531 GROUP BY depo_id
)AS v_sblm_tpp ON d.depo_id = v_sblm_tpp.depo_id
GROUP BY d.depo_id, d.depo_code, d.depo_name;

