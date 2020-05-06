requirements: requirements-to-freeze.txt
	@docker run --rm -v $$(pwd):/usr/src/app/ python:3 /bin/bash -c "python3 -m pip install --upgrade pip && python3 -m pip install -r /usr/src/app/requirements-to-freeze.txt && python3 -m pip freeze > /usr/src/app/requirements.txt"
