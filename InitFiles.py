# coding=utf-8
import os, shutil, argparse
from glob import glob

#Item = ['nodif.nii.gz', 'nodif_brain.nii.gz', 'dtifitresult_MD.nii.gz', 'dtifitresult_FA.nii.gz', 'dtifitresult_L1.nii.gz', 'dtifitresult_L2.nii.gz', 'dtifitresult_L3.nii.gz']
Item = ['T1.nii', 'iwT1_brain.nii', 'uiwT1_brain.nii', 'wT1_brain.nii','y_T1.nii','iy_T1.nii']

def InitFile(args):
    for subject in open(args.List, "r"):
        subject = subject.strip('\n')
        print("Subject: ", subject)
        prefixDir = args.MainFolder + subject + '*'
        dirs = glob(prefixDir)
        for dir in dirs:
            dirname = os.path.split(dir)[1]
            Newdir = args.NewFolder + dirname
            if not os.path.exists(Newdir):
                os.makedirs(Newdir)
                print("NewFolder: ", Newdir)
            for item in Item:
                src = dir + "/" + item
                dst = Newdir + "/" + item
                shutil.copyfile(src, dst)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-m", "--MainFolder", help="raw data folder", required=True)
    parser.add_argument("-l", "--List", help="Subject List", required=True)
    parser.add_argument("-n", "--NewFolder", help="New Folder", required=True)
    # parser.add_argument("-i", "--Item", help="Item(Name.Type) to copy", required=True)
    args = parser.parse_args()
    InitFile(args)
