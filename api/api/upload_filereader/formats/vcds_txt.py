import codecs
import logging as log
import re
from typing import BinaryIO, List

import cchardet as chardet

from ..filereader import FileReader, FileReaderException

OBD_ERROR = re.compile(
    r"^\s*(?P<error_code>[BCPU][01][0-7][0-9A-Z]{2})\s"
    r"\d{2} \[\d{3}\] - (?P<error_string>.*)\s*$")
VIN_AND_MILAGE = re.compile(
    r"^.+: (?P<vin>[A-HJ-NPR-Za-hj-npr-z0-9]{17})\s*"
    r".+: (?P<milage>\d+)km\s*$")
VCDS_INFO = re.compile(
    r"^\s*.+: DRV (?P<driver_version>[0-9A-Fa-f.]+)\s*"
    r"HEX-V2 CB: (?P<hex_v2>[0-9A-Fa-f.]+)\s*$")


class VCDSTXTReader(FileReader):
    def read_file(self, file: BinaryIO) -> List[dict]:
        enc = self.__determine_encoding(file)
        return self.__read_vcds_txt(file, enc)

    def probe(self, file: BinaryIO):
        enc = self.__determine_encoding(file)
        validated = self.__get_obd_specs(file, enc)
        file.seek(0)
        return validated

    def __get_obd_specs(self, file: BinaryIO, enc: str):
        try:
            file_iter = codecs.iterdecode(file, enc)
            for _ in range(0, 6):
                vcds_info = VCDS_INFO.match(next(file_iter).rstrip('\r\n'))
                if vcds_info:
                    log.debug(
                        "Found VCDS File with Driver Ver: {} HEX_V2: {}"
                        "".format(
                            vcds_info['driver_version'], vcds_info['hex_v2'])
                    )
                    obd_specs = {
                        'device': 'VCDS',
                        'drv_ver': vcds_info['driver_version'],
                        'fw_ver': vcds_info['hex_v2']
                    }
                    file.seek(0)
                    return obd_specs

        except Exception:
            raise FileReaderException(
                "conversion failed: Failed to read filehead"
            )

    def __determine_encoding(self, file: BinaryIO):
        encoding = chardet.detect(file.read())['encoding']
        file.seek(0)
        return encoding

    def __read_vcds_txt(self, file: BinaryIO, enc: str):
        obd_specs = self.__get_obd_specs(file, enc)
        if not obd_specs:
            raise FileReaderException("conversion error: invalid vcds file")
        file_iter = codecs.iterdecode(file, enc)
        result = {}
        dtcs = []
        found_vam = False
        for line in file_iter:
            line = line.rstrip('\r\n')
            if not found_vam:
                vam = VIN_AND_MILAGE.match(line)
                if vam:
                    result['vehicle'] = {'vin': vam['vin']}
                    result['case'] = {'milage': int(vam['milage'])}
                    found_vam = True
            obd_code = OBD_ERROR.match(line)
            if obd_code:
                dtcs.append(obd_code['error_code'])
        result['obd_data'] = {
            'dtcs': dtcs,
            'obd_specs': obd_specs
        }
        # all file readers return a list
        result = [result]
        return result