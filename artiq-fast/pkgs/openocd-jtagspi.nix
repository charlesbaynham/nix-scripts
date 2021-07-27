diff '--color=auto' -Naur openocd-0.11.0/src/flash/nor/jtagspi.c openocd-0.11.0.new/src/flash/nor/jtagspi.c
--- openocd-0.11.0/src/flash/nor/jtagspi.c	2020-12-10 03:43:09.000000000 +0800
+++ openocd-0.11.0.new/src/flash/nor/jtagspi.c	2021-07-27 18:31:32.179205804 +0800
@@ -82,7 +82,7 @@
 	struct scan_field fields[6];
 	uint8_t marker = 1;
 	uint8_t xfer_bits_buf[4];
-	uint8_t addr_buf[3];
+	uint8_t addr_buf[4];
 	uint8_t *data_buf;
 	uint32_t xfer_bits;
 	int is_read, lenb, n;
@@ -102,9 +102,12 @@
 
 	xfer_bits = 8 + len - 1;
 	/* cmd + read/write - 1 due to the counter implementation */
-	if (addr)
-		xfer_bits += 24;
-	h_u32_to_be(xfer_bits_buf, xfer_bits);
+	if (addr) {
+		if (bank->size > (1 << 24))
+			xfer_bits += 32;
+		else
+			xfer_bits += 24;
+	}
 	flip_u8(xfer_bits_buf, xfer_bits_buf, 4);
 	fields[n].num_bits = 32;
 	fields[n].out_value = xfer_bits_buf;
@@ -118,9 +121,15 @@
 	n++;
 
 	if (addr) {
-		h_u24_to_be(addr_buf, *addr);
-		flip_u8(addr_buf, addr_buf, 3);
-		fields[n].num_bits = 24;
+		if (bank->size > (1 << 24)) {
+			h_u32_to_be(addr_buf, *addr);
+			flip_u8(addr_buf, addr_buf, 4);
+			fields[n].num_bits = 32;
+		} else {
+			h_u24_to_be(addr_buf, *addr);
+			flip_u8(addr_buf, addr_buf, 3);
+			fields[n].num_bits = 24;
+		}
 		fields[n].out_value = addr_buf;
 		fields[n].in_value = NULL;
 		n++;
@@ -304,11 +313,14 @@
 	struct jtagspi_flash_bank *info = bank->driver_priv;
 	int retval;
 	int64_t t0 = timeval_ms();
+	uint8_t erase_cmd = info->dev->erase_cmd;
 
 	retval = jtagspi_write_enable(bank);
 	if (retval != ERROR_OK)
 		return retval;
-	jtagspi_cmd(bank, info->dev->erase_cmd, &bank->sectors[sector].offset, NULL, 0);
+	if (bank->size > (1 << 24))
+		erase_cmd = SPIFLASH_4BYTE_SECTOR_ERASE;
+	jtagspi_cmd(bank, erase_cmd, &bank->sectors[sector].offset, NULL, 0);
 	retval = jtagspi_wait(bank, JTAGSPI_MAX_TIMEOUT);
 	LOG_INFO("sector %u took %" PRId64 " ms", sector, timeval_ms() - t0);
 	return retval;
@@ -374,24 +386,36 @@
 static int jtagspi_read(struct flash_bank *bank, uint8_t *buffer, uint32_t offset, uint32_t count)
 {
 	struct jtagspi_flash_bank *info = bank->driver_priv;
+	uint8_t read_cmd = SPIFLASH_READ;
 
 	if (!(info->probed)) {
 		LOG_ERROR("Flash bank not yet probed.");
 		return ERROR_FLASH_BANK_NOT_PROBED;
 	}
+	if (count >= (1 << 28)) {
+		LOG_ERROR("Read too large.");
+		return ERROR_FAIL;
+	}
 
-	jtagspi_cmd(bank, SPIFLASH_READ, &offset, buffer, -count*8);
+	if (bank->size > (1 << 24))
+		read_cmd = SPIFLASH_4BYTE_READ;
+	jtagspi_cmd(bank, read_cmd, &offset, buffer, -count*8);
 	return ERROR_OK;
 }
 
 static int jtagspi_page_write(struct flash_bank *bank, const uint8_t *buffer, uint32_t offset, uint32_t count)
 {
 	int retval;
+	uint8_t program_cmd = SPIFLASH_PAGE_PROGRAM;
 
 	retval = jtagspi_write_enable(bank);
 	if (retval != ERROR_OK)
 		return retval;
-	jtagspi_cmd(bank, SPIFLASH_PAGE_PROGRAM, &offset, (uint8_t *) buffer, count*8);
+
+	if (bank->size > (1 << 24))
+		program_cmd = SPIFLASH_4BYTE_PAGE_PROGRAM;
+
+	jtagspi_cmd(bank, program_cmd, &offset, (uint8_t *) buffer, count*8);
 	return jtagspi_wait(bank, JTAGSPI_MAX_TIMEOUT);
 }
 
diff '--color=auto' -Naur openocd-0.11.0/src/flash/nor/spi.h openocd-0.11.0.new/src/flash/nor/spi.h
--- openocd-0.11.0/src/flash/nor/spi.h	2020-12-10 03:43:09.000000000 +0800
+++ openocd-0.11.0.new/src/flash/nor/spi.h	2021-07-27 18:32:08.106935700 +0800
@@ -87,6 +87,9 @@
 #define SPIFLASH_PAGE_PROGRAM	0x02 /* Page Program */
 #define SPIFLASH_FAST_READ		0x0B /* Fast Read */
 #define SPIFLASH_READ			0x03 /* Normal Read */
+#define SPIFLASH_4BYTE_READ		0x13 /* Read with 4 byte address */
+#define SPIFLASH_4BYTE_SECTOR_ERASE	0xDC /* Sector Erase with 4 byte address */
+#define SPIFLASH_4BYTE_PAGE_PROGRAM	0x12 /* Page Program with 4 byte address */
 #define SPIFLASH_MASS_ERASE		0xC7 /* Mass Erase */
 #define SPIFLASH_READ_SFDP		0x5A /* Read Serial Flash Discoverable Parameters */
 
