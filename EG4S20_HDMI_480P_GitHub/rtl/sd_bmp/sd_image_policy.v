// First-release policy placeholder: first valid partition, root directory,
// short name IMAGE.BMP. FAT parsing is intentionally not claimed yet.
module sd_image_policy(output wire [31:0] first_partition_lba);
    assign first_partition_lba=32'd0;
endmodule
