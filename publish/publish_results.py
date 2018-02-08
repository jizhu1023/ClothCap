import os
import shutil
import argparse

ALL_RESULTS_ORIGIN = "../all_results"
ALL_RESULTS_PUBLISH = "./all_results"

TYPES = ["single-mesh", "segmentation", "multi-cloth"]


def publish_segmentation(frames_folder, result_folder_origin, result_folder_publish):
    for frame_result in frames_folder:
        path_origin = os.path.join(result_folder_origin, frame_result)
        if not os.path.isdir(path_origin):
            continue
        print("[info] publishing", frame_result)

        path_publish = os.path.join(result_folder_publish, frame_result)
        os.mkdir(path_publish)

        for _, _, files in os.walk(path_origin):
            for result_file in files:
                if result_file.endswith("_seg_scan.obj") or result_file.endswith("_seg_smpl.obj") or \
                        result_file.endswith("_colored.obj"):
                    shutil.copy(os.path.join(path_origin, result_file), os.path.join(path_publish, result_file))


def main():
    # parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("--type", dest="result_type",
                        help="result type, [single-mesh|segmentation|multi-cloth].")
    parser.add_argument("--scan", dest="scan_name", help="scan sequences folder name.")
    parsed_args = parser.parse_args()

    result_type = parsed_args.result_type
    scan_name = parsed_args.scan_name

    if result_type not in TYPES:
        print("[error] invalid result type, [single-mesh|segmentation|multi-cloth].")
        print("[error] aborting ...")
        exit(-1)

    # origin results
    all_results_origin = os.path.join(os.getcwd(), ALL_RESULTS_ORIGIN)
    all_results_origin = os.path.realpath(all_results_origin)

    if not os.path.exists(all_results_origin):
        print("[error] please run 'publish_results.py' in 'publish' folder.")
        print("[error] aborting ...")
        exit(-1)

    results_folder_origin = os.path.join(all_results_origin, result_type)
    results_folder_origin = os.path.join(results_folder_origin, scan_name)

    if not os.path.exists(results_folder_origin):
        print("[error] no sequences", scan_name, "found.")
        print("[error] aborting ...")
        exit(-1)

    # published results folder
    all_results_publish = os.path.join(os.getcwd(), ALL_RESULTS_PUBLISH)
    all_results_publish = os.path.realpath(all_results_publish)

    if not os.path.exists(all_results_publish):
        os.mkdir(all_results_publish)

    result_folder_publish = os.path.join(all_results_publish, result_type)
    if not os.path.exists(result_folder_publish):
        os.mkdir(result_folder_publish)

    result_folder_publish = os.path.join(result_folder_publish, scan_name)
    if os.path.exists(result_folder_publish):
        shutil.rmtree(result_folder_publish)
    os.mkdir(result_folder_publish)

    frames_folder = os.listdir(results_folder_origin)

    if result_type == "segmentation":
        publish_segmentation(frames_folder, results_folder_origin, result_folder_publish)


if __name__ == "__main__":
    main()
