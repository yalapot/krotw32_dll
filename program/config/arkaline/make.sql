DB_LOG _trcobj.log

DB_MAKE _trcobj.mdb trcobj.def

INSERT INTO dct_feat_size (id, name, code_name) VALUES (0, 'NULL', 'NONE')
INSERT INTO dct_feat_size (id, name, code_name) VALUES (1, '���������� �������', 'AXGR')
INSERT INTO dct_feat_size (id, name, code_name) VALUES (2, '���������� ����', 'AXSL')
INSERT INTO dct_feat_size (id, name, code_name) VALUES (3, '���������� �������', 'CIGR')
INSERT INTO dct_feat_size (id, name, code_name) VALUES (4, '���������� ����', 'CISL')
INSERT INTO dct_feat_size (id, name, code_name) VALUES (5, '��������', 'GENE')
INSERT INTO dct_feat_size (id, name, code_name) VALUES (6, '����', 'PINH')
INSERT INTO dct_feat_size (id, name, code_name) VALUES (7, '�������', 'PITT')

INSERT INTO objtypes (id, name, tbl)      VALUES (4,   '�����', 'defect')
INSERT INTO objtypes (id, name, tbl)      VALUES (5,   '��������', 'defect')
INSERT INTO objtypes (id, name, tbl)      VALUES (6,   '���������� �������', 'defect')
INSERT INTO objtypes (id, name, tbl)      VALUES (7,   '���� ��������', 'defect')
INSERT INTO objtypes (id, name, tbl)      VALUES (8,   '������� ����������', 'defect')
INSERT INTO objtypes (id, name, tbl)      VALUES (9,   '������� ����������', 'defect')
INSERT INTO objtypes (id, name, tbl)      VALUES (10,  '�������', 'defect')
INSERT INTO objtypes (id, name, tbl)      VALUES (11,  '��������', 'defect')
INSERT INTO objtypes (id, name, tbl)      VALUES (12,  '��������������', 'defect')
INSERT INTO objtypes (id, name, tbl)      VALUES (13,  '������-��������', 'defect')
INSERT INTO objtypes (id, name, tbl)      VALUES (14,  '���� ������', 'defect')
INSERT INTO objtypes (id, name, tbl)      VALUES (15,  '�������', 'defect')
INSERT INTO objtypes (id, name, tbl, off) VALUES (16,  '����������', 'defect', 1)
INSERT INTO objtypes (id, name, tbl)      VALUES (17,  '��������� ����', 'defect')
INSERT INTO objtypes (id, name, tbl)      VALUES (18,  '�������', 'defect')
INSERT INTO objtypes (id, name, tbl)      VALUES (19,  '���������� ���. ��������', 'defect')
INSERT INTO objtypes (id, name, tbl)      VALUES (20,  '���.����', 'lin_obj')
INSERT INTO objtypes (id, name, tbl, off) VALUES (21,  '������������ ����', 'lin_obj', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (22,  '������ ����� �����', 'lin_obj', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (23,  '�����', 'lin_obj', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (24,  '��������', 'lin_obj', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (25,  '��������� ������', 'lin_obj', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (26,  '������ ���������', 'lin_obj', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (27,  '������� �������', 'lin_obj', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (28,  '���. ��������, ������. � �.�.', 'lin_obj', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (29,  '�����. �������', 'lin_obj', 1)
INSERT INTO objtypes (id, name, tbl)      VALUES (30,  '������ �������', 'lin_obj')
INSERT INTO objtypes (id, name, tbl, off) VALUES (31,  '���������. ������', 'lin_obj', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (32,  '�����. ��������', 'lin_obj', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (33,  '������� ������������', 'lin_obj', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (34,  '��������. ���������. ��-�', 'lin_obj', 1)
INSERT INTO objtypes (id, name, tbl)      VALUES (40,  '������ ������', 'lin_obj')
INSERT INTO objtypes (id, name, tbl)      VALUES (60,  '����� ������� ���������', '')
INSERT INTO objtypes (id, name, tbl)      VALUES (70,  '����', 'lin_obj')
INSERT INTO objtypes (id, name, tbl)      VALUES (80,  '������', 'lin_obj')
INSERT INTO objtypes (id, name, tbl)      VALUES (81,  '��������� ������', 'lin_obj')
INSERT INTO objtypes (id, name, tbl)      VALUES (110, '������ ������� ���������', '')
INSERT INTO objtypes (id, name, tbl)      VALUES (120, '������ ������', 'lin_obj')
INSERT INTO objtypes (id, name, tbl)      VALUES (130, '���� � ������', 'lin_obj')
INSERT INTO objtypes (id, name, tbl)      VALUES (131, '����� �� �������', 'lin_obj')
INSERT INTO objtypes (id, name, tbl)      VALUES (132, '�������', 'lin_obj')
INSERT INTO objtypes (id, name, tbl)      VALUES (133, '���� � ������', 'lin_obj')
INSERT INTO objtypes (id, name, tbl)      VALUES (134, '����� �� �������', 'lin_obj')
INSERT INTO objtypes (id, name, tbl)      VALUES (140, '������� �������', 'thick')
INSERT INTO objtypes (id, name, tbl)      VALUES (141, '��������� �������', 'thick')
INSERT INTO objtypes (id, name, tbl)      VALUES (160, '�������', 'turn')
INSERT INTO objtypes (id, name, tbl)      VALUES (161, '���� � ����', 'lin_obj')
INSERT INTO objtypes (id, name, tbl)      VALUES (162, '����� �� ����', 'lin_obj')
INSERT INTO objtypes (id, name, tbl)      VALUES (163, '������ �������', 'defect')
INSERT INTO objtypes (id, name, tbl)      VALUES (164, '������ ���. �����', 'lin_obj')
INSERT INTO objtypes (id, name, tbl)      VALUES (165, '����� ���. �����', 'lin_obj')
INSERT INTO objtypes (id, name, tbl)      VALUES (170, '�������', '')
INSERT INTO objtypes (id, name, tbl, off) VALUES (180, '����������� ����� ���������', '', 1)
INSERT INTO objtypes (id, name, tbl)      VALUES (190, '����������� �����', 'weld')
INSERT INTO objtypes (id, name, tbl)      VALUES (191, '������������� �����', 'weld')
INSERT INTO objtypes (id, name, tbl)      VALUES (192, '��c������ �����', 'weld')
INSERT INTO objtypes (id, name, tbl, off) VALUES (193, '�������������� ������', 'weld', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (194, '����������', 'weld', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (195, '����������', 'weld', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (200, '����. ��������� ���', 'defect', 1)
INSERT INTO objtypes (id, name, tbl)      VALUES (201, '����. �� �������. ���', 'defect')
INSERT INTO objtypes (id, name, tbl, off) VALUES (202, '�������� / �������', 'defect', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (203, '������', 'defect', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (204, '�������� ������', 'defect', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (205, '������ ������', 'defect', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (206, '���������� ������', 'defect', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (207, '����. ��������. ���', 'defect', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (208, '����. ��������. ���', 'defect', 1)
INSERT INTO objtypes (id, name, tbl)      VALUES (209, '����. � ���. ������ ���.', 'defect')
INSERT INTO objtypes (id, name, tbl, off) VALUES (210, '������������� ����������', 'defect', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (211, '�����. ������� ������. ����� ���.', 'defect', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (212, '�����. ������� ������. ����� ���.', 'defect', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (213, '����������� ���� �������', 'defect', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (214, '������������� ������', 'defect', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (215, '������ ����. � ������', 'defect', 1)
INSERT INTO objtypes (id, name, tbl)      VALUES (216, '����������', 'defect')
INSERT INTO objtypes (id, name, tbl)      VALUES (217, '������ �������', 'defect')
INSERT INTO objtypes (id, name, tbl)      VALUES (218, '�������� ��������', 'defect')
INSERT INTO objtypes (id, name, tbl, off) VALUES (219, '������', 'defect', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (220, '���������� � ���. �� ���-�����', 'defect', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (221, '������� ���������', 'defect', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (222, '������� �� ��������� ���', 'defect', 1)
INSERT INTO objtypes (id, name, tbl, off) VALUES (223, '������������ ������������ ����', 'defect', 1)
INSERT INTO objtypes (id, name, tbl)      VALUES (224, '���������� �������', 'defect')
INSERT INTO objtypes (id, name, tbl, off) VALUES (225, '���������� ����������� ���', 'defect', 1)
INSERT INTO objtypes (id, name, tbl)      VALUES (226, '����������', 'defect')
INSERT INTO objtypes (id, name, tbl)      VALUES (227, '���������������� ������', 'defect')

INSERT INTO trcConfig (distMode, odoKoef, odoStart) VALUES (0, 1, 0)
