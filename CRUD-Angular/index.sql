BEGIN
    SELECT * FROM (
        SELECT
            NULL AS Cod_Record,
            A.Cod_Record AS Cod_ErpSellOrderItem,
            A.Cod_ErpProductOrService,
            CONCAT(B.Cod_Record, ' - ', B.Nam_Object) AS Nam_ErpProductOrService,
            A.Val_UOM,
            C.Nam_Domain AS Nam_UOM,
            A.Val_ErpSellOrderPriceType AS Ind_ErpSellOrderPriceType,
            D.Nam_Domain AS Nam_ErpSellOrderPriceType,
            fn_GetErpSellOrderItemAvailableValue(IN_Cod_ErpSellOrder, IN_Cod_ErpSellOrderDER, 
                A.Cod_ErpProductOrService, A.Val_UOM, IN_Ind_ErpSellOrderPriceType, A.Cod_Record) AS Val_QuantityActual,
            '0,00' AS Val_Quantity,
            A.Des_Observation,
            E.Val_MinQuantity AS Val_MinQuantity,
            E.Val_MaxQuantity AS Val_MaxQuantity
        FROM 
            tb_ErpSellOrderItem A
            INNER JOIN tb_ErpProductOrService B
                ON A.Cod_ErpProductOrService = B.Cod_Record
            INNER JOIN tb_Domain C
                ON A.Val_UOM = C.Val_Domain
                AND C.Nam_DomainType = 'UnitOfMeasure'
            INNER JOIN tb_Domain D
                ON A.Val_ErpSellOrderPriceType = D.Val_Domain
                AND D.Nam_DomainType = 'ErpSellOrderPriceType'
            LEFT JOIN tb_ErpProgressiveDiscountItem E
            ON A.Cod_ErpProgressiveDiscountItem = E.Cod_Record
        WHERE 
            A.Cod_ErpSellOrder = IN_Cod_ErpSellOrder
        AND A.Cod_Record NOT IN(
            SELECT Cod_ErpSellOrderItem FROM tb_ErpSellOrderDERItem X
            WHERE X.Cod_ErpSellOrderDER = IN_Cod_ErpSellOrderDER)
        AND (IN_Ind_ErpSellOrderPriceType IS NULL OR A.Val_ErpSellOrderPriceType = IN_Ind_ErpSellOrderPriceType)
        AND IN_Cod_ErpSellOrderDER IS NULL
    ) AS Y WHERE fn_ToDecimal(Y.Val_QuantityActual) > 0 
UNION ALL
	SELECT
		X.Cod_Record,
		X.Cod_ErpSellOrderItem,
		A.Cod_ErpProductOrService,
		CONCAT(B.Cod_Record, ' - ', B.Nam_Object) AS Nam_ErpProductOrService,
		A.Val_UOM,
		C.Nam_Domain AS Nam_UOM,
		A.Val_ErpSellOrderPriceType AS Ind_ErpSellOrderPriceType,
		D.Nam_Domain AS Nam_ErpSellOrderPriceType,
		fn_FormatDecimal(
		fn_ToDecimal(
			fn_GetErpSellOrderItemAvailableValue(A.Cod_ErpSellOrder, X.Cod_ErpSellOrderDER, 
				A.Cod_ErpProductOrService, A.Val_UOM, A.Val_ErpSellOrderPriceType, A.Cod_Record)
		) + fn_ToDecimal(X.Val_Quantity)) AS Val_QuantityActual,
		X.Val_Quantity,
		A.Des_Observation,
		E.Val_MinQuantity AS Val_MinQuantity,
		E.Val_MaxQuantity AS Val_MaxQuantity
	FROM
		tb_ErpSellOrderDERItem X
		INNER JOIN tb_ErpSellOrderItem A
			ON X.Cod_ErpSellOrderItem = A.Cod_Record
		INNER JOIN tb_ErpProductOrService B
			ON A.Cod_ErpProductOrService = B.Cod_Record
		INNER JOIN tb_Domain C
			ON A.Val_UOM = C.Val_Domain
			AND C.Nam_DomainType = 'UnitOfMeasure'
		INNER JOIN tb_Domain D
			ON A.Val_ErpSellOrderPriceType = D.Val_Domain
			AND D.Nam_DomainType = 'ErpSellOrderPriceType'
		LEFT JOIN tb_ErpProgressiveDiscountItem E
			ON A.Cod_ErpProgressiveDiscountItem = E.Cod_Record
	WHERE
		X.Cod_ErpSellOrderDER = IN_Cod_ErpSellOrderDER
	AND (IN_Ind_ErpSellOrderPriceType IS NULL OR A.Val_ErpSellOrderPriceType = IN_Ind_ErpSellOrderPriceType);
END