import os
import pytest

from unittest import mock
from string import ascii_lowercase, digits
from pprint import pprint
from copy import deepcopy

import virtool.viruses

FIXTURE_DIR = os.path.join(os.path.dirname(os.path.realpath(__file__)), "test_files")


@pytest.fixture
def iresine():
    return {
        "last_indexed_version": 0,
        "abbreviation": "IrVd",
        "modified": False,
        "_id": "008lgo",
        "name": "Iresine viroid",
        "isolates": [
            {
                "source_name": "",
                "isolate_id": "6kplarn7",
                "source_type": "unknown",
                "default": True
            }
        ]
    }


@pytest.fixture
def iresine_sequence():
    return {
        "sequence": "CGTGGTT",
        "_id": "NC_003613",
        "host": "Iresine herbstii",
        "definition": "Iresine viroid complete sequence",
        "length": 370,
        "isolate_id": "6kplarn7"
    }


@pytest.fixture
def duplicate_result():
    return {"isolate_id": [], "_id": [], "name": [], "sequence_id": [], "abbreviation": []}


class TestProcessor:

    def test(self, test_virus):
        expected = deepcopy(test_virus)
        expected["virus_id"] = expected.pop("_id")

        processed = virtool.viruses.processor(test_virus)

        assert processed == expected


class TestJoin:

    async def test(self, test_motor, test_virus, test_sequence, test_merged_virus):
        """
        Test that a virus is properly joined when only a ``virus_id`` is provided.
        
        """
        await test_motor.viruses.insert(test_virus)
        await test_motor.sequences.insert(test_sequence)

        joined = await virtool.viruses.join(test_motor, "6116cba1")

        assert joined == test_merged_virus

    async def test_document(self, monkeypatch, mocker, test_motor, test_virus, test_sequence, test_merged_virus):
        """
        Test that the virus is joined using a passed ``document`` when provided. Ensure that another ``find_one`` call
        to the virus collection is NOT made.
         
        """
        stub = mocker.stub(name="find_one")

        async def async_stub(*args, **kwargs):
            stub(*args, **kwargs)
            return test_virus

        monkeypatch.setattr("motor.motor_asyncio.AsyncIOMotorCollection.find_one", async_stub)

        await test_motor.viruses.insert(test_virus)
        await test_motor.sequences.insert(test_sequence)

        assert not stub.called

        document = await test_motor.viruses.find_one()

        assert stub.called

        stub.reset_mock()

        assert not stub.called

        joined = await virtool.viruses.join(test_motor, "6116cba1", document)

        assert not stub.called

        assert joined == test_merged_virus


class TestCheckNameAndAbbreviation:

    @pytest.mark.parametrize("name,abbreviation,return_value", [
        ("Foobar Virus", "FBR", False),
        ("Prunus virus F", "FBR", "Name already exists"),
        ("Foobar Virus", "PVF", "Abbreviation already exists"),
        ("Prunus virus F", "PVF", "Name and abbreviation already exist"),
    ])
    async def test(self, name, abbreviation, return_value, test_motor, test_virus):
        """
        Test that the function works properly for all possible inputs.
         
        """
        await test_motor.viruses.insert_one(test_virus)

        result = await virtool.viruses.check_name_and_abbreviation(test_motor, name, abbreviation)

        assert result == return_value


class TestImportFile:

    async def test(self, mocker, loop, test_motor, test_import_handle):
        stub = mocker.stub(name="dispatch")

        result = await virtool.viruses.import_file(loop, test_motor, stub, test_import_handle, "test", replace=False)

        status_calls = [call[0] for call in stub.call_args_list if call[0][0] == "status"]

        assert all(args[1] == "update" for args in status_calls)

        expected = {
            'skipped': 0,
            'file_size': 0,
            'conflicts': None,
            'duplicates': None,
            'in_progress': True,
            'inserted': 0,
            'warnings': [],
            'virus_count': 1,
            'replaced': 0,
            'file_name': 'viruses.json.gz',
            'id': 'import_viruses',
            'errors': None, 'progress': 0
        }

        assert status_calls[0][2] == expected

        expected["progress"] = 1

        assert status_calls[1][2] == expected

        expected["inserted"] = 1

        assert status_calls[2][2] == expected

        assert result == {
            "inserted": 1,
            "progress": 1,
            "replaced": 0,
            "skipped": 0,
            "warnings": []
        }

        assert 0

    '''

    @pytest.mark.gen_test
    def test_empty_collection(self, monkeypatch, mock_pymongo, import_transaction, viruses_collection, import_report,
                              import_json):
        """
        Ensure that the json_data fixture for monkey patching the read_import_file function work properly.

        """
        @virtool.gen.synchronous
        def return_json(*args):
            return import_json

        monkeypatch.setattr("virtool.virusutils.read_import_file", return_json)

        transaction = import_transaction()

        yield viruses_collection.import_file(transaction)

        # Check that history.Collection.add was called three times.
        assert viruses_collection.collections["history"].stubs["add_for_import"].call_count == 5

        # Check the the correct numbers of documents were inserted.
        assert mock_pymongo.viruses.count() == 5
        assert mock_pymongo.sequences.count() == 11

        # Check that the final call to transaction.update matches what we expect.
        import_report["added"] = 5
        assert transaction.update_called == (True, import_report)

    @pytest.mark.gen_test
    @pytest.mark.parametrize("duplicates, errors", [(True, True), (True, None), (None, True), (None, None)])
    def test_verification(self, monkeypatch, mock_pymongo, import_transaction, viruses_collection, import_json,
                          duplicates, errors):
        """
        Make sure verification errors terminate the import process and are dispatched properly. Also ensure that an
        absence of verification errors does not falsely terminate the import process.

        """
        @virtool.gen.synchronous
        def return_json(*args):
            return import_json

        @virtool.gen.coroutine
        def verify_virus_list(*args):
            return duplicates, errors

        monkeypatch.setattr("virtool.virusutils.read_import_file", return_json)
        monkeypatch.setattr("virtool.virusutils.verify_virus_list", verify_virus_list)

        transaction = import_transaction()

        yield viruses_collection.import_file(transaction)

        success, data = transaction.fulfill_called

        # Check that no documents were inserted.
        count = mock_pymongo.viruses.count()

        if duplicates is None and errors is None:
            assert count == 5
            assert success
        else:
            assert count == 0
            assert not success
            assert data["message"] == "Invalid import file"
            assert data["duplicates"] is duplicates
            assert data["errors"] is errors

    @pytest.mark.gen_test
    @pytest.mark.parametrize("conflicts", [["sequence"], None])
    def test_conflicts(self, monkeypatch, mock_pymongo, import_transaction, viruses_collection, import_json, conflicts):
        """
        Make sure sequence id conflicts terminate the import process and are dispatched properly. Also ensure that an
        the import process is not spuriously terminated in the absence of conflicts.

        """
        @virtool.gen.synchronous
        def return_json(*args):
            return import_json

        @virtool.gen.coroutine
        def find_import_conflicts(*args):
            return conflicts

        monkeypatch.setattr("virtool.virusutils.read_import_file", return_json)
        monkeypatch.setattr("virtool.viruses.Collection.find_import_conflicts", find_import_conflicts)

        transaction = import_transaction()

        yield viruses_collection.import_file(transaction)

        success, data = transaction.fulfill_called

        # Check that no documents were inserted.
        count = mock_pymongo.viruses.count()

        if conflicts is None:
            assert count == 5
            assert success
        else:
            assert count == 0
            assert not success
            assert data["message"] == "Conflicting sequence ids"
            assert data["conflicts"] == ["sequence"]

    @pytest.mark.gen_test
    def test_existing_abbreviation(self, monkeypatch, virus_document, import_transaction, viruses_collection,
                                   mock_pymongo, import_json):
        """
        Make sure that the abbreviation for an existing virus document is retained when it is also used in an imported
        virus. Also check that the abbreviation is stripped from the imported virus, thus ensuring abbreviations remain
        unique.

        """
        @virtool.gen.synchronous
        def return_json(*args):
            imported = import_json[0:3]
            imported[0]["abbreviation"] = "CMV"
            return imported

        monkeypatch.setattr("virtool.virusutils.read_import_file", return_json)

        virus_document["username"] = "test"

        yield viruses_collection.insert(virus_document)

        transaction = import_transaction()

        yield viruses_collection.import_file(transaction)

        warning = "Abbreviation CMV already existed for virus Cucumber mosaic virus and was not assigned to new virus" \
                  " Iresine viroid."

        assert transaction.fulfill_called[1]["warnings"][0] == warning

        # Make sure the abbreviation is retained on the pre-existing document.
        assert mock_pymongo.viruses.count({"name": "Cucumber mosaic virus", "abbreviation": "CMV"}) == 1

        # Make sure there is only one occurrence of the abbreviation.
        assert mock_pymongo.viruses.count({"abbreviation": "CMV"}) == 1

    @pytest.mark.gen_test
    def test_replacement(self, monkeypatch, virus_document, merged_virus, import_transaction, viruses_collection,
                         mock_pymongo, import_json):
        """
        When a virus exists in the database and the import file and the ``replace`` options is set, make sure that
        existing viruses are removed and the new virus is inserted. Check that history was updated to reflect the
        changes.

        """
        virus_document["username"] = "test"

        @virtool.gen.synchronous
        def return_json(*args):
            imported = import_json[0:3]
            imported.append(merged_virus)
            return imported

        monkeypatch.setattr("virtool.virusutils.read_import_file", return_json)

        virus_document["_version"] = 10

        yield viruses_collection.insert(virus_document)

        assert 1 == mock_pymongo.viruses.count({
            "_id": virus_document["_id"],
            "_version": 10,
            "name": "Cucumber mosaic virus"
        })

        transaction = import_transaction({"replace": True})

        yield viruses_collection.import_file(transaction)

        assert mock_pymongo.viruses.count({"_version": 0, "name": "Cucumber mosaic virus"}) == 1

        assert mock_pymongo.viruses.count() == 4

        assert mock_pymongo.sequences.count() == 9

        # There should be 4 history additions for inserting new viruses and 1 addition for removing the existing CMV.
        calls = [c[1] for c in viruses_collection.collections["history"].stubs["add_for_import"].mock_calls]

        assert len([call for call in calls if call[0] == "insert"]) == 4
        assert len([call for call in calls if call[0] == "remove"]) == 1

        assert transaction.fulfill_called == (
            True,
            {"added": 3, "replaced": 1, "skipped": 0, "warnings": [], "progress": 1}
        )

    @pytest.mark.gen_test
    def test_no_replacement(self, monkeypatch, virus_document, merged_virus, import_transaction, viruses_collection,
                            mock_pymongo, import_json):
        """
        When a virus exists in the database and the import file and the ``replace`` options is not set, make sure that
        existing viruses are retained and the new virus is discarded. Check that no virus was removed.

        """
        virus_document["username"] = "test"

        @virtool.gen.synchronous
        def return_json(*args):
            imported = import_json[0:3]
            imported.append(merged_virus)
            return imported

        monkeypatch.setattr("virtool.virusutils.read_import_file", return_json)

        virus_document["_version"] = 10

        yield viruses_collection.insert(virus_document)

        assert 1 == mock_pymongo.viruses.count({
            "_id": virus_document["_id"],
            "_version": 10,
            "name": "Cucumber mosaic virus"
        })

        transaction = import_transaction({"replace": False})

        yield viruses_collection.import_file(transaction)

        assert 1 == mock_pymongo.viruses.count({
            "_id": virus_document["_id"],
            "_version": 10,
            "name": "Cucumber mosaic virus"
        })

        assert mock_pymongo.viruses.count() == 4

        # Seven instead of nine because the initially inserted virus was not added with any sequences.
        assert mock_pymongo.sequences.count() == 7

        # There should be 4 history additions for inserting new viruses and 1 addition for removing the existing CMV.
        calls = [c[1] for c in viruses_collection.collections["history"].stubs["add_for_import"].mock_calls]

        assert len([call for call in calls if call[0] == "insert"]) == 3
        assert len([call for call in calls if call[0] == "remove"]) == 0

        assert transaction.fulfill_called == (
            True,
            {"added": 3, "replaced": 0, "skipped": 1, "warnings": [], "progress": 1}
        )
    '''


class TestCheckVirus:

    def test_pass(self, test_virus, test_sequence):
        """
        Test that a valid virus and sequence list results in return value of ``None``.
         
        """
        result = virtool.viruses.check_virus(test_virus, [test_sequence])
        assert result is None

    def test_empty_isolate(self, test_virus):
        """
        Test that an isolate with no sequences is detected.
         
        """
        result = virtool.viruses.check_virus(test_virus, [])

        assert result == {
            "empty_isolate": ["cab8b360"],
            "empty_sequence": False,
            "empty_virus": False,
            "isolate_inconsistency": False
        }

    def test_empty_sequence(self, test_virus, test_sequence):
        """
        Test that a sequence with an empty ``sequence`` field is detected.
         
        """
        test_sequence["sequence"] = ""

        result = virtool.viruses.check_virus(test_virus, [test_sequence])

        assert result == {
            "empty_isolate": False,
            "empty_sequence": [{
                "_id": "KX269872",
                "definition": "Prunus virus F isolate 8816-s2 segment RNA2 polyprotein 2 gene, complete cds.",
                "host": "sweet cherry",
                "isolate_id": "cab8b360",
                "sequence": ""
            }],
            "empty_virus": False,
            "isolate_inconsistency": False
        }

    def test_empty_virus(self, test_virus):
        """
        Test that an virus with no isolates is detected.
         
        """
        test_virus["isolates"] = []

        result = virtool.viruses.check_virus(test_virus, [])

        assert result == {
            "empty_isolate": False,
            "empty_sequence": False,
            "empty_virus": True,
            "isolate_inconsistency": False
        }

    def test_isolate_inconsistency(self, test_virus, test_sequence):
        """
        Test that isolates in a single virus with disparate sequence counts are detected. 
         
        """
        test_virus["isolates"].append(dict(test_virus["isolates"][0], isolate_id="foobar"))

        sequences = [
            test_sequence,
            dict(test_sequence, _id="foobar_1", isolate_id="foobar"),
            dict(test_sequence, _id="foobar_2", isolate_id="foobar")
        ]

        pprint(test_virus)

        pprint(sequences)

        result = virtool.viruses.check_virus(test_virus, sequences)

        assert result == {
            "empty_isolate": False,
            "empty_sequence": False,
            "empty_virus": False,
            "isolate_inconsistency": True
        }


class TestVerifyVirusList:
    def test_valid(self, test_virus_list):
        """
        Test that a valid virus list returns no duplicates or errors.

        """
        result = virtool.viruses.verify_virus_list(test_virus_list)
        assert result == (None, None)

    @pytest.mark.parametrize("multiple", [False, True])
    def test_duplicate_virus_ids(self, multiple, test_virus_list):
        test_virus_list[0]["_id"] = "067jz0t3"

        if multiple:
            test_virus_list[3]["_id"] = "067jz213"

        duplicates, error = virtool.viruses.verify_virus_list(test_virus_list)

        assert error is None

        assert all([duplicates[key] == [] for key in ["isolate_id", "name", "abbreviation", "sequence_id"]])

        expected = {"067jz0t3"}

        if multiple:
            expected.add("067jz213")

        assert set(duplicates["_id"]) == expected

    def test_empty_abbreviations(self, test_virus_list, duplicate_result):
        """
        Ensure that abbreviations with value "" are not counted as duplicates.

        """
        test_virus_list[0]["abbreviation"] = ""
        test_virus_list[1]["abbreviation"] = ""

        result = virtool.viruses.verify_virus_list(test_virus_list)

        assert result == (None, None)

    @pytest.mark.parametrize("multiple", [False, True])
    def test_duplicate_abbreviations(self, multiple, test_virus_list):
        """
        Test that duplicate abbreviations are detected. Use parametrization to test if single and multiple occurrences
        are detected.

        """
        test_virus_list[0]["abbreviation"] = "TST"

        if multiple:
            test_virus_list[3]["abbreviation"] = "EXV"

        duplicates, error = virtool.viruses.verify_virus_list(test_virus_list)

        assert error is None

        for key in ["isolate_id", "name", "_id", "sequence_id"]:
            assert duplicates[key] == []

        expected = {"TST"}

        if multiple:
            expected.add("EXV")

        assert set(duplicates["abbreviation"]) == expected

    @pytest.mark.parametrize("multiple", [False, True])
    def test_duplicate_names(self, multiple, test_virus_list):
        """
        Test that duplicate virus names are detected. Use parametrization to test if single and multiple occurrences are
        detected.

        """
        # Add a duplicate virus name to the list.
        test_virus_list[1]["name"] = "Prunus virus F"

        if multiple:
            test_virus_list[3]["name"] = "Example virus"

        duplicates, error = virtool.viruses.verify_virus_list(test_virus_list)

        assert error is None

        assert all([duplicates[key] == [] for key in ["isolate_id", "_id", "sequence_id"]])

        expected = {"prunus virus f"}

        if multiple:
            expected.add("example virus")

        assert set(duplicates["name"]) == expected

    @pytest.mark.parametrize("multiple", [False, True])
    def test_duplicate_sequence_ids(self, multiple, test_virus_list):
        """
        Test that duplicate sequence ids in a virus list are detected. Use parametrization to test if single and
        multiple occurrences are detected.

        """
        test_virus_list[0]["isolates"][0]["sequences"].append(
            dict(test_virus_list[0]["isolates"][0]["sequences"][0])
        )

        if multiple:
            test_virus_list[1]["isolates"][0]["sequences"].append(
                dict(test_virus_list[1]["isolates"][0]["sequences"][0])
            )

        duplicates, error = virtool.viruses.verify_virus_list(test_virus_list)

        assert error is None

        assert all([duplicates[key] == [] for key in ["isolate_id", "_id", "name", "abbreviation"]])

        expected = {test_virus_list[0]["isolates"][0]["sequences"][0]["_id"]}

        if multiple:
            expected.add(test_virus_list[1]["isolates"][0]["sequences"][0]["_id"])

        assert set(duplicates["sequence_id"]) == expected

    def test_isolate_inconsistency(self, test_virus_list):
        """
        Test that viruses containing isolates associated with disparate numbers of sequences are detected.

        """
        extra_isolate = deepcopy(test_virus_list[0]["isolates"][0])

        test_virus_list[0]["isolates"].append(extra_isolate)

        extra_isolate.update({
            "_id": "extra",
            "isolate_id": "extra"
        })

        extra_isolate["sequences"][0].update({
            "_id": "extra_0",
            "isolate_id": "extra"
        })

        extra_sequence = dict(test_virus_list[0]["isolates"][0]["sequences"][0])

        extra_sequence.update({
            "_id": "extra_1",
            "isolate_id": "extra"
        })

        extra_isolate["sequences"].append(extra_sequence)

        duplicates, errors = virtool.viruses.verify_virus_list(test_virus_list)

        assert duplicates is None

        assert errors["prunus virus f"]["isolate_inconsistency"]

    @pytest.mark.parametrize("multiple", [False, True])
    def test_empty_virus(self, multiple, test_virus_list):
        """
        Test that viruses with no isolates are detected. Use parametrization to test if single and multiple occurrences
        are detected.

        """
        test_virus_list[0]["isolates"] = list()

        if multiple:
            test_virus_list[1]["isolates"] = list()

        duplicates, errors = virtool.viruses.verify_virus_list(test_virus_list)

        assert duplicates is None

        assert errors["prunus virus f"]["empty_virus"]

        if multiple:
            assert errors["test virus"]["empty_virus"] is True

    @pytest.mark.parametrize("multiple", [False, True])
    def test_empty_isolate(self, multiple, test_virus_list):
        """
        Test that isolates with no sequences are detected. Use parametrization to test if single and multiple
        occurrences are detected.

        """
        test_virus_list[0]["isolates"][0]["sequences"] = list()

        if multiple:
            test_virus_list[1]["isolates"][0]["sequences"] = list()

        duplicates, errors = virtool.viruses.verify_virus_list(test_virus_list)

        assert errors["prunus virus f"]["empty_isolate"] == ["cab8b360"]

        if multiple:
            assert errors["test virus"]["empty_isolate"] == ["second_0"]

    @pytest.mark.parametrize("multiple", [False, True])
    def test_empty_sequences(self, multiple, test_virus_list):
        """
        Test that sequences with empty ``sequence`` fields are detected. Use parametrization to test if single and
        multiple occurrences are detected.

        """
        test_virus_list[1]["isolates"][0]["sequences"][0]["sequence"] = ""

        if multiple:
            test_virus_list[2]["isolates"][0]["sequences"][0]["sequence"] = ""

        duplicates, errors = virtool.viruses.verify_virus_list(test_virus_list)

        assert duplicates is None

        assert errors["test virus"]["empty_sequence"][0]["_id"] == "second_seq_0"

        if multiple:
            assert errors["example virus"]["empty_sequence"][0]["_id"] == "third_seq_0"


class TestFindImportConflicts:

    async def test_empty_collection(self, test_motor, test_virus_list):
        """
        Test that no conflicts are found when the sequence collection is empty.

        """
        result = await virtool.viruses.find_import_conflicts(test_motor, test_virus_list, False)

        assert result is None

    async def test_no_conflicts(self, test_motor, test_virus_list, iresine, iresine_sequence):
        """
        Test that no conflicts are found when the sequence collection is populated, but there really are no conflicts.

        """
        await test_motor.viruses.insert(iresine)
        await test_motor.sequences.insert(iresine_sequence)

        result = await virtool.viruses.find_import_conflicts(test_motor, test_virus_list, False)

        assert result is None

    @pytest.mark.parametrize("replace", [True, False])
    async def test_existing_sequence_id(self, replace, test_motor, test_virus_list, iresine, iresine_sequence):
        """
        Test that a conflict is found when ``replace`` is ``True`` or ``False`` and an imported sequence id already
        exists in the database.

        """
        await test_motor.viruses.insert(iresine)
        await test_motor.sequences.insert(iresine_sequence)

        # Replace CMV's first sequence id with the one from ``iresine_sequence``. This creates a situation in which we
        # are attempting to import a sequence id (NC_003613) that already exists in another virus (IrVd).
        test_virus_list[0]["isolates"][0]["sequences"][0]["_id"] = "NC_003613"

        result = await virtool.viruses.find_import_conflicts(test_motor, test_virus_list, replace)

        assert result == [('008lgo', 'Iresine viroid', 'NC_003613')]

    async def test_existing_sequence_id_same_virus(self, test_motor, test_virus_list, iresine, iresine_sequence):
        """
        Test that no conflict is found when ``replace`` is ``True`` and and imported sequence id already exists in the
        same virus as the one being imported.

        """
        iresine.update({
            "user_id": "test",
            "lower_name": "iresine viroid"
        })

        await test_motor.viruses.insert(iresine)
        await test_motor.sequences.insert(iresine_sequence)

        iresine["isolates"][0]["sequences"] = [iresine_sequence]

        test_virus_list.append(iresine)

        result = await virtool.viruses.find_import_conflicts(test_motor, test_virus_list, True, ["iresine viroid"])

        assert result is None


class TestSendImportDispatches:
    def test_insertions(self, mocker, get_test_insertions):
        insertions = get_test_insertions()

        viruses, changes = zip(*deepcopy(insertions))

        stub = mocker.stub(name="dispatch")

        virtool.viruses.send_import_dispatches(stub, insertions, [])

        viruses_call, history_call = stub.mock_calls

        assert viruses_call == mock.call("viruses", "update", viruses)

        assert history_call == mock.call("history", "update", changes)

    def test_replacements(self, mocker, get_test_replacements):
        replacements = get_test_replacements()

        remove, insert = zip(*deepcopy(replacements))

        viruses_1, changes_1 = [list(t) for t in zip(*remove)]
        viruses_2, changes_2 = [list(t) for t in zip(*insert)]

        stub = mocker.stub(name="dispatch")

        virtool.viruses.send_import_dispatches(stub, [], replacements)

        assert len(stub.mock_calls) == 4

        viruses_call_1, history_call_1, viruses_call_2, history_call_2 = stub.mock_calls

        assert viruses_call_1 == mock.call("viruses", "remove", viruses_1)
        assert history_call_1 == mock.call("history", "update", changes_1)

        assert viruses_call_2 == mock.call("viruses", "update", viruses_2)
        assert history_call_2 == mock.call("history", "update", changes_2)

    @pytest.mark.parametrize("replacement", [True, False])
    @pytest.mark.parametrize("count", [28, 30, 0])
    def test_too_few(self, replacement, count, mocker, get_test_insertions, get_test_replacements):

        insertions = []
        replacements = []

        if replacement:
            replacements = get_test_replacements(count)
        else:
            insertions = get_test_insertions(count)

        stub = mocker.stub(name="dispatch")

        virtool.viruses.send_import_dispatches(stub, insertions, replacements)

        if replacement:
            if count == 30:
                assert len(stub.mock_calls) == 4
            else:
                assert not stub.mock_calls

        else:
            if count == 30:
                assert len(stub.mock_calls) == 2
            else:
                assert not stub.mock_calls


class TestInsertFromImport:

    async def test(self, static_time, test_motor, test_virus, test_sequence):
        """
        Test that function returns a processed virus document and change document.
         
        """
        joined = virtool.viruses.merge_virus(test_virus, [test_sequence])

        virus, change = await virtool.viruses.insert_from_import(test_motor, joined, "test")

        assert virus == {
            "abbreviation": "PVF",
            "modified": False,
            "name": "Prunus virus F",
            "version": 0,
            "virus_id": "6116cba1"
        }

        assert change == {
            "change_id": "6116cba1.0",
            "description": ("Created virus ", "Prunus virus F", "6116cba1"),
            "index": "unbuilt",
            "index_version": "unbuilt",
            "method_name": "create",
            "timestamp": static_time,
            "user_id": "test",
            "virus_id": "6116cba1",
            "virus_name": "Prunus virus F",
            "virus_version": "0"
        }


class TestDeleteForImport:

    async def test(self, static_time, test_motor, test_virus, test_sequence):
        """
        Test that function returns the removed ``virus_id`` and a processed change document ready for dispatch.

        """
        await test_motor.viruses.insert_one(test_virus)
        await test_motor.sequences.insert_one(test_sequence)

        virus_id, change = await virtool.viruses.delete_for_import(test_motor, test_virus["_id"], "test")

        assert virus_id == test_virus["_id"]

        assert change == {
            "change_id": "6116cba1.removed",
            "description": ("Removed virus", "Prunus virus F", "6116cba1"),
            "index": "unbuilt",
            "index_version": "unbuilt",
            "method_name": "remove",
            "timestamp": static_time,
            "user_id": "test",
            "virus_id": "6116cba1",
            "virus_name": "Prunus virus F",
            "virus_version": "removed"
        }


class TestUpdateLastIndexedVersion:

    async def test(self, test_motor, test_virus):
        """
        Test that function works as expected.
         
        """
        virus_1 = test_virus
        virus_2 = deepcopy(test_virus)

        virus_2.update({
            "_id": "foobar"
        })

        await test_motor.viruses.insert_many([virus_1, virus_2])

        result = await virtool.viruses.update_last_indexed_version(test_motor, ["foobar"], 5)

        assert result == {"updatedExisting": True, "nModified": 1, "ok": 1.0, "n": 1}

        virus_1 = await test_motor.viruses.find_one({"_id": "6116cba1"})
        virus_2 = await test_motor.viruses.find_one({"_id": "foobar"})

        assert virus_1["version"] == 0
        assert virus_1["last_indexed_version"] == 0

        assert virus_2["version"] == 5
        assert virus_2["last_indexed_version"] == 5


class TestGetDefaultIsolate:

    def test(self, test_virus, test_isolate):
        """
        Test that the function can find the default isolate.
         
        """
        default_isolate = dict(test_isolate, isolate_id="foobar3", default=True)

        test_virus["isolates"] = [
            dict(test_isolate, isolate_id="foobar1", default=False),
            dict(test_isolate, isolate_id="foobar2", default=False),
            default_isolate,
            dict(test_isolate, isolate_id="foobar4", default=False)
        ]

        pprint(test_virus["isolates"])

        assert virtool.viruses.get_default_isolate(test_virus) == default_isolate

    def test_processor(self, test_virus, test_isolate):
        """
        Test that the ``processor`` argument works.
         
        """

        default_isolate = dict(test_isolate, isolate_id="foobar3", default=True)

        expected = dict(default_isolate, processed=True)

        test_virus["isolates"] = [
            dict(test_isolate, isolate_id="foobar1", default=False),
            default_isolate
        ]

        def test_processor(isolate):
            return dict(isolate, processed=True)

        assert virtool.viruses.get_default_isolate(test_virus, test_processor) == expected

    def test_no_default(self, test_virus):
        """
        Test that a ``ValueError`` is raised when the virus contains not default isolates. 
         
        """
        test_virus["isolates"][0]["default"] = False

        with pytest.raises(ValueError) as err:
            virtool.viruses.get_default_isolate(test_virus)

        assert "No default isolate found" in str(err)

    def test_multiple_defaults(self, test_virus, test_isolate):
        """
        Test that a ``ValueError`` is raised when the virus contains more than one default isolate. 

        """
        extra_isolate = dict(test_isolate, isolate_id="foobar3", default=True)

        test_virus["isolates"].append(extra_isolate)

        with pytest.raises(ValueError) as err:
            virtool.viruses.get_default_isolate(test_virus)

        assert "Found more than one" in str(err)


class TestGetNewIsolateId:

    async def test(self, test_motor, test_virus):
        await test_motor.viruses.insert(test_virus)

        new_id = await virtool.viruses.get_new_isolate_id(test_motor)

        allowed = ascii_lowercase + digits

        assert all(c in allowed for c in new_id)

    async def test_exists(self, test_motor, test_virus, test_random_alphanumeric):
        """
        Test that a different ``isolate_id`` is generated if the first generated one already exists in the database.        
         
        """
        next_choice = test_random_alphanumeric.next_choice[:8].lower()

        expected = test_random_alphanumeric.choices[1][:8].lower()

        test_virus["isolates"][0]["isolate_id"] = next_choice

        await test_motor.viruses.insert(test_virus)

        new_id = await virtool.viruses.get_new_isolate_id(test_motor)

        assert new_id == expected

    async def test_excluded(self, test_motor, test_random_alphanumeric):
        """
        Test that a different ``isolate_id`` is generated if the first generated one is in the ``excluded`` list.        

        """
        excluded = [test_random_alphanumeric.next_choice[:8].lower()]

        expected = test_random_alphanumeric.choices[1][:8].lower()

        new_id = await virtool.viruses.get_new_isolate_id(test_motor, excluded=excluded)

        assert new_id == expected

    async def test_exists_and_excluded(self, test_motor, test_virus, test_random_alphanumeric):
        """
        Test that a different ``isolate_id`` is generated if the first generated one is in the ``excluded`` list.        

        """
        excluded = [test_random_alphanumeric.choices[2][:8].lower()]

        test_virus["isolates"][0]["isolate_id"] = test_random_alphanumeric.choices[1][:8].lower()

        await test_motor.viruses.insert(test_virus)

        expected = test_random_alphanumeric.choices[0][:8].lower()

        new_id = await virtool.viruses.get_new_isolate_id(test_motor, excluded=excluded)

        assert new_id == expected


class TestMergeVirus:

    def test(self, test_virus, test_sequence, test_merged_virus):
        merged = virtool.viruses.merge_virus(test_virus, [test_sequence])

        assert merged == test_merged_virus


class TestSplitVirus:

    def test(self, test_virus, test_sequence, test_merged_virus):
        virus, sequences = virtool.viruses.split_virus(test_merged_virus)

        assert virus == test_virus
        assert sequences == [test_sequence]


class TestExtractIsolateIds:

    def test_merged_virus(self, test_merged_virus):
        isolate_ids = virtool.viruses.extract_isolate_ids(test_merged_virus)
        assert isolate_ids == ["cab8b360"]

    def test_virus_document(self, test_virus):
        isolate_ids = virtool.viruses.extract_isolate_ids(test_virus)
        assert isolate_ids == ["cab8b360"]

    def test_multiple(self, test_virus):
        test_virus["isolates"].append({
            "source_type": "isolate",
            "source_name": "b",
            "isolate_id": "foobar",
            "default": False
        })

        isolate_ids = virtool.viruses.extract_isolate_ids(test_virus)

        assert set(isolate_ids) == {"cab8b360", "foobar"}

    def test_missing_isolates(self, test_virus):
        del test_virus["isolates"]

        with pytest.raises(KeyError):
            virtool.viruses.extract_isolate_ids(test_virus)


class TestFindIsolate:

    def test(self, test_virus, test_isolate):
        new_isolate = dict(test_isolate, isolate_id="foobar", source_type="isolate", source_name="b")

        test_virus["isolates"].append(new_isolate)

        isolate = virtool.viruses.find_isolate(test_virus["isolates"], "foobar")

        assert isolate == new_isolate

    def test_does_not_exist(self, test_virus):
        assert virtool.viruses.find_isolate(test_virus["isolates"], "foobar") is None


class TestExtractSequenceIds:

    def test_valid(self, test_merged_virus):
        sequence_ids = virtool.viruses.extract_sequence_ids(test_merged_virus)
        assert sequence_ids == ["KX269872"]

    def test_missing_isolates(self, test_merged_virus):
        del test_merged_virus["isolates"]

        with pytest.raises(KeyError) as err:
            virtool.viruses.extract_sequence_ids(test_merged_virus)

        assert "'isolates'" in str(err)

    def test_empty_isolates(self, test_merged_virus):
        test_merged_virus["isolates"] = list()

        with pytest.raises(ValueError) as err:
            virtool.viruses.extract_sequence_ids(test_merged_virus)

        assert "Empty isolates list" in str(err)

    def test_missing_sequences(self, test_merged_virus):
        del test_merged_virus["isolates"][0]["sequences"]

        with pytest.raises(KeyError) as err:
            virtool.viruses.extract_sequence_ids(test_merged_virus)

        assert "missing sequences field" in str(err)

    def test_empty_sequences(self, test_merged_virus):
        test_merged_virus["isolates"][0]["sequences"] = list()

        with pytest.raises(ValueError) as err:
            virtool.viruses.extract_sequence_ids(test_merged_virus)

        assert "Empty sequences list" in str(err)


class TestFormatIsolateName:

    @pytest.mark.parametrize("source_type, source_name", [("Isolate", ""), ("Isolate", ""), ("", "8816 - v2")])
    def test(self, source_type, source_name, test_isolate):
        """
        Test that a formatted isolate name is produced for a full ``source_type`` and ``source_name``. Test that if
        either of these fields are missing, "Unnamed isolate" is returned.
         
        """
        test_isolate.update({
            "source_type": source_type,
            "source_name": source_name
        })

        print(source_type, source_name)

        formatted = virtool.viruses.format_isolate_name(test_isolate)

        if source_type and source_name:
            assert formatted == "Isolate 8816 - v2"
        else:
            assert formatted == "Unnamed Isolate"
